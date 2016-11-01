//
//  MeetingsViewController.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 12.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit

class MeetingsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

	@IBOutlet weak var controllerTitleLabel: UILabel!
    private var needDownload = true
    private var currentOffset: Int = 0
    private var users: [FBSearchedUser] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
	
	var currentSelection : Int = -1{
		didSet{
			self.updateMeetUsers();
		}
	}
	
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.controllerTitleLabel.text = "_MEETINGS".localized
		self.segmentSelector.setTitle("_I_WANT_TO_MEET".localized, forSegmentAtIndex: 0);
		self.segmentSelector.setTitle("_WHO_WANTS_TO_MEET_ME".localized, forSegmentAtIndex: 1);
        self.filterButton.hidden = true
        self.searchButton.hidden = true
        self.deleteButton.hidden = true
        self.collectionView.registerClass(EmptyCollectionCell.self, forCellWithReuseIdentifier: "EmptyListCell");
        self.activity.startAnimating()
		
		self.menuBg = UIImageView(frame: UIScreen.mainScreen().bounds);
		self.menuBg.image = nil
        self.updateMainImage()
        FBEvent.onMainPictChanged().listen(self) { [unowned self] (_) -> Void in
            self.updateMainImage()
        }
		self.view.addSubview(self.menuBg);
		self.view.sendSubviewToBack(self.menuBg);
		self.view.bringSubviewToFront(self.segmentSelector);
    }
	var menuBg : UIImageView!;
    private func updateMainImage() {
		UserProfile.getMainPict({ (image) -> Void in
			self.menuBg.image = image
			if(self.menuBg.subviews.count == 0){
				let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
				let blurView = UIVisualEffectView(effect: blurEffect)
				blurView.frame = self.menuBg.bounds
				self.menuBg.addSubview(blurView)
			}
		})
		

    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
		
		let selection = self.currentSelection == -1 ? 0 : self.currentSelection;
		self.currentSelection = selection;
		FBoxHelper.getMainController()?.showMenuButton(true)
    }
    
    // MARK: - Outlets
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var segmentSelector: UISegmentedControl!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Actions
    @IBAction func segmentAction(sender: AnyObject) {
		self.currentSelection = self.segmentSelector.selectedSegmentIndex
    }
	
    private func updateMeetUsers(offset: Int = 0) {
        self.currentOffset = offset
        if self.currentOffset == 0 {
            needDownload = true
            self.users = []
            self.collectionView.reloadData()
            self.activity.startAnimating()
        }
        if self.currentSelection == 0 {
            Net.iWantToMeet(currentOffset, limit: FBoxConstants.kDefaultLimit).onSuccess { (users) -> Void in
                self.appendUsers(users)
            }
        }else{
            Net.whoWantsToMeetMe(currentOffset, limit: FBoxConstants.kDefaultLimit).onSuccess { (users) -> Void in
                self.appendUsers(users)
            }
        }
    }
    private func appendUsers(users: [FBSearchedUser]) {
        if users.count == 0 || users.count < FBoxConstants.kDefaultLimit {
            self.needDownload = false
        }
        self.activity.stopAnimating()
        for user in users {
            if !self.isUserContains(user) {
                self.users.append(user)
            }
        }
        self.collectionView.reloadData()
    }
    private func isUserContains(user: FBSearchedUser) -> Bool {
        var isContained = false
        for usr in self.users {
            if usr.username == user.username {
                isContained = true
                break
            }
        }
        return isContained
    }
    
    // MARK: - UICollectionView
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count == 0 ? 1 : users.count;
	}
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		if(users.count == 0){
			let emptyCell = collectionView.dequeueReusableCellWithReuseIdentifier("EmptyListCell", forIndexPath: indexPath) as! EmptyCollectionCell
			emptyCell.frame = CGRect(x: 0,y: 0,width: UIScreen.mainScreen().bounds.width,height: 100);
			emptyCell.textLabel.frame = emptyCell.bounds;
			emptyCell.userInteractionEnabled = false;
			return emptyCell;
		}
        let collectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("OnlineCollectionViewCell", forIndexPath: indexPath)
        if let onlineCollectionViewCell = collectionViewCell as? OnlineCollectionViewCell {
            onlineCollectionViewCell.userPicture.layer.borderWidth = 2.0
            onlineCollectionViewCell.userPicture.layer.masksToBounds = false
            onlineCollectionViewCell.userPicture.layer.borderColor = UIColor.whiteColor().CGColor
            onlineCollectionViewCell.userPicture.layer.cornerRadius = onlineCollectionViewCell.userPicture.frame.size.width/2.0
            onlineCollectionViewCell.userPicture.clipsToBounds = true
            let user = users[indexPath.row]
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
        if self.users.count > 0 && indexPath.row > self.users.count - 2 && self.needDownload {
            updateMeetUsers(self.users.count)
        }
        return collectionViewCell
    }
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let onlineCollectionViewCell = cell as? OnlineCollectionViewCell {
            onlineCollectionViewCell.userPicture.nk_cancelLoading()
        }
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let user = users[indexPath.row]
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ProfileViewController") as? ProfileViewController {
            controller.user = user
            FBoxHelper.getMainController()?.hideMenuButton(true)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
