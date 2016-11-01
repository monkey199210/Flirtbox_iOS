//
//  RadarViewController.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 13.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit

class RadarViewController: UIViewController, ValueSelectorDelegate, FBRadarViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

	@IBOutlet weak var controllerTopLabel: UILabel!
    private var lat: Double = 0.0
    private var lon: Double = 0.0
    
    // MARK: - Lifecycle
    private var radarViewController: FBRadarViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
		self.controllerTopLabel.text = "_RADAR".localized;
        distanceSelector.delegate = self
        self.topDotsButton.hidden = true
        let radar = FBRadarViewController(nibName: "RadarViewController", bundle: nil)
        radar.delegate = self
        radar.willMoveToParentViewController(self)
        self.addChildViewController(radar)
        radar.view.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(radar.view, aboveSubview: distanceSelector)
        radar.didMoveToParentViewController(self)
        
        view.addConstraint(NSLayoutConstraint(item: radar.view, attribute: .CenterX, relatedBy: .Equal, toItem: centerAvatar, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: radar.view, attribute: .CenterY, relatedBy: .Equal, toItem: centerAvatar, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: radar.view, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 400.0))
        view.addConstraint(NSLayoutConstraint(item: radar.view, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 400.0))
        
        radarViewController = radar
        self.distance.text = "0"
        
        LocationManager.sharedInstance.setHeadingProcessBlock { (rotation) -> () in
            UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
                self.locationPointer.transform = CGAffineTransformMakeRotation(CGFloat(-rotation))
                self.radarViewController.view.transform = CGAffineTransformMakeRotation(CGFloat(-rotation))
                self.radarViewController.rotateImages(CGFloat(rotation))
                }, completion:nil)
        }
        var isRetrieved = false
        LocationManager.sharedInstance.setLocationProcessBlock { (lat, lon) -> () in
            self.lat = lat
            self.lon = lon
            if !isRetrieved {
                isRetrieved = true
                self.retrieveUsers()
            }
        }
        view.bringSubviewToFront(centerAvatar)
        
        self.closeButton.userInteractionEnabled = false
        self.bottomConstraint.constant = -self.bottomHeight.constant
        self.view.layoutIfNeeded()
        self.menuBg.image = nil
        self.centerAvatar.image = nil
        centerAvatar.layer.borderWidth = 2.0
        centerAvatar.layer.masksToBounds = false
        centerAvatar.layer.borderColor = UIColor.whiteColor().CGColor
        centerAvatar.layer.cornerRadius = centerAvatar.frame.size.width/2.0
        centerAvatar.clipsToBounds = true
        self.updateMainImage()
        FBEvent.onMainPictChanged().listen(self) { [unowned self] (_) -> Void in
            self.updateMainImage()
        }
        FBEvent.onAuthenticated().listen(self) { [unowned self] (isAuthenticated) -> Void in
            if isAuthenticated {
                self.updateMainImage()
            }else{
                self.centerAvatar.image = nil
            }
        }
    }
    private func updateMainImage() {
        UserProfile.getMainPict({ (image) -> Void in
            self.menuBg.image = image
            UserProfile.getCircledMainImage({ (image) -> Void in
                self.centerAvatar.image = image
            })
        })
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        FBoxHelper.getMainController()?.showMenuButton(true)
        LocationManager.sharedInstance.startUpdating()
        radarViewController.runSpinAnimation()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        LocationManager.sharedInstance.stopUpdating()
    }

    // MARK: - Outlets
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var menuBg: UIImageView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var topDotsButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomHeight: NSLayoutConstraint!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var centerAvatar: UIImageView!
    @IBOutlet weak var locationPointer: UIImageView!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var distanceSelector: ValueSelector!
    
    // MARK: - Actions
    @IBAction func closeAction(sender: AnyObject) {
        closeBottomList()
    }
    
    // MARK: - ValueSelectorDelegate
    func valueChanged(valueSelector: ValueSelector, value: CGFloat) {
        var revertedValue = valueSelector.maxValue - value
        revertedValue = max(revertedValue, 10.0)
        self.distance.text = "\(String(Int(revertedValue)))"
        radarViewController.animateWaves()
    }
    func valueSelected(valueSelector: ValueSelector, value: CGFloat) {
        var revertedValue = valueSelector.maxValue - value
        revertedValue = max(revertedValue, 10.0)
        radarViewController.allowedUsers = Int(revertedValue)
    }
    
    // MARK: - Helper methods
    private let kMaxLatitude: Double = 90.0
    private let kMaxLongitude: Double = 180.0
    private var users: [FBSearchedUser] = [] {
        didSet {
            var radarUsers: [UserData] = []
            for searchedUser in users {
                if let lat = searchedUser.latitude as? NSNumber, let lon = searchedUser.longitude as? NSNumber {
                    var imageUrl: String
                    if let avatar = searchedUser.avatar {
                        imageUrl = avatar.hasPrefix("http") ? avatar : FBNet.PROFILE_PIC_SMALL + avatar
                    }else{
                        imageUrl = FBNet.PROFILE_DEFAULT_PIC
                    }
                    let latitude = Double(lat)
                    let longitude = Double(lon)
                    var x = longitude - self.lon
                    var y = latitude - self.lat
                    x *= kCoordToMeters
                    y *= kCoordToMeters
                    radarUsers.append(UserData(username: searchedUser.username, imageUrl: imageUrl, x: CGFloat(x), y: CGFloat(y)))
                }
            }
            radarUsers.sortInPlace { (first, second) -> Bool in
                return first.distance < second.distance
            }
            if radarUsers.count > 0 {
                self.distanceSelector.maxValue = CGFloat(radarUsers.count)
                self.distanceSelector.value = 0
                self.radarViewController.clear()
                self.radarViewController.allUsers = radarUsers
            }
        }
    }
    private var isSearching = false {
        didSet {
            if isSearching {
                self.activity.startAnimating()
            }else{
                self.activity.stopAnimating()
            }
        }
    }
    private let kSearchLimit = 50
    private let kMetersToMiles: Double = 0.000621371
    private let kCoordToMeters: Double = 100000
    private func retrieveUsers() {
        if !isSearching {
            isSearching = true
            Net.search(Double(distanceSelector.maxValue) * kMetersToMiles, offset: 0, limit: kSearchLimit, lat: self.lat, lon: self.lon, sortField: .Lastactive).onSuccess { (users) -> Void in
                self.isSearching = false
                self.users = users
            }.onFailure(callback: { (_) -> Void in
                self.isSearching = false
            })
        }
    }
    private func openBottomList() {
        self.bottomConstraint.constant = 0.0
        UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.infoView.alpha = 0.0
            self.distanceSelector.alpha = 0.0
            self.view.layoutIfNeeded()
            }, completion:nil)
    }
    private func closeBottomList() {
        self.closeButton.userInteractionEnabled = false
        self.bottomConstraint.constant = -self.bottomHeight.constant
        UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.infoView.alpha = 1.0
            self.distanceSelector.alpha = 1.0
            self.view.layoutIfNeeded()
            }, completion:nil)
    }
    // MARK: - FBRadarViewControllerDelegate
	func groupTapped(userIds: [String], reset: Bool) {
        selectedUsers.removeAll()
		if(reset){
			self.closeBottomList()
			return;
		}
        for user in self.users {
            if userIds.contains(user.username) {
                selectedUsers.append(user)
            }
        }
        if selectedUsers.count > 1 {
            self.collectionView.reloadData()
            openBottomList()
        }else if selectedUsers.count == 1 {
            if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ProfileViewController") as? ProfileViewController {
                controller.user = selectedUsers.first!
                FBoxHelper.getMainController()?.hideMenuButton(true)
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    func pinched(scale: CGFloat) {
        var distance = self.distanceSelector.value
        distance += 2000 * scale
        self.distanceSelector.value = distance
    }
    
    // MARK: - UICollectionView
    private var selectedUsers: [FBSearchedUser] = []
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedUsers.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let collectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("OnlineCollectionViewCell", forIndexPath: indexPath)
        if let onlineCollectionViewCell = collectionViewCell as? OnlineCollectionViewCell {
            onlineCollectionViewCell.userPicture.layer.borderWidth = 2.0
            onlineCollectionViewCell.userPicture.layer.masksToBounds = false
            onlineCollectionViewCell.userPicture.layer.borderColor = UIColor.whiteColor().CGColor
            onlineCollectionViewCell.userPicture.layer.cornerRadius = onlineCollectionViewCell.userPicture.frame.size.width/2.0
            onlineCollectionViewCell.userPicture.clipsToBounds = true
            let user = selectedUsers[indexPath.row]
            onlineCollectionViewCell.userName.text = user.username
            onlineCollectionViewCell.userLocation.text = user.town
            var imageUrl: String
            if let avatar = user.avatar {
                imageUrl = avatar.hasPrefix("http") ? avatar : FBNet.PROFILE_PIC_SMALL + avatar
            }else{
                imageUrl = FBNet.PROFILE_DEFAULT_PIC
            }
            if let url = NSURL(string: imageUrl) {
                onlineCollectionViewCell.userPicture.nk_cancelLoading()
                onlineCollectionViewCell.userPicture.nk_setImageWith(url)
            }
        }
        return collectionViewCell
    }
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let onlineCollectionViewCell = cell as? OnlineCollectionViewCell {
            onlineCollectionViewCell.userPicture.nk_cancelLoading()
        }
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let user = selectedUsers[indexPath.row]
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ProfileViewController") as? ProfileViewController {
            controller.user = user
            FBoxHelper.getMainController()?.hideMenuButton(true)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
