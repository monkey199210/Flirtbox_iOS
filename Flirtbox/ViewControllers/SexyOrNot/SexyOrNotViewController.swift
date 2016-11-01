//
//  SexyOrNotViewController.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 13.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit
import Nuke

class SexyOrNotViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, TemperatureViewDelegate {


    // MARK: - Lifecycle
    private let kDefaultLimit = 50
    private let kDefaultDistance = "2000"
    private var picturesOffset = 0
    private var users: [FBSexyOrNotUser] = []
    override func viewDidLoad() {
        super.viewDidLoad()
		self.controllerTitleLabel.text = "_SEXYORNOT".localized;
        self.temperatureView.delegate = self
        self.collectionViewTop.constant = -UIApplication.sharedApplication().statusBarFrame.height
        self.view.layoutIfNeeded()
		self.loadPictures()
    }
	override func viewWillAppear(animated: Bool){
		super.viewWillAppear(animated);
		FBoxHelper.getMainController()?.showMenuButton(true);
	}
    private var isLoading = false
    private var needDownload = true
    private func loadPictures() {
        if !isLoading {
            isLoading = true
            if users.count == 0 {
                self.activity.startAnimating()
            }
			
            Net.sexyOrNot(LocationManager.sharedInstance.longitude, latitude: LocationManager.sharedInstance.latitude, distance: kDefaultDistance, offset: picturesOffset, limit: kDefaultLimit).onSuccess(callback: { (users) -> Void in
                if users.count == 0 {
                    self.needDownload = false
                }
                self.users.appendContentsOf(users)
                self.collectionView.reloadData()
                self.isLoading = false
                self.picturesOffset += self.kDefaultLimit
                self.activity.stopAnimating()
            }).onFailure(callback: { (_) -> Void in
                self.isLoading = false
                self.activity.stopAnimating()
            })
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var temperatureButtonImage: UIImageView!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var temperatureSeletedButtonImage: UIImageView!
    @IBOutlet weak var temperatureView: TemperatureView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var collectionViewTop: NSLayoutConstraint!
    @IBOutlet weak var topDotsButton: UIButton!
    @IBOutlet weak var bottomView: EventsSendView!
    @IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var usernameLabel: UILabel!
	@IBOutlet weak var controllerTitleLabel: UILabel!
    // MARK: - Actions
    
    @IBAction func backAction(sender: AnyObject) {
        if let prevIndexPath = self.getPreviousIndexPath() {
            self.collectionView.scrollToItemAtIndexPath(prevIndexPath, atScrollPosition: .None, animated: true)
        }
    }
    @IBAction func forwardAction(sender: AnyObject) {
        if let nextIndexPath = self.getNextIndexPath() {
            self.collectionView.scrollToItemAtIndexPath(nextIndexPath, atScrollPosition: .None, animated: true)
        }
    }
	@IBAction func revealProfile(sender: AnyObject) {
		Net.userData(self.users[currentIndexPath!.row].uname, animated: true).onSuccess(callback: { (user) -> Void in
			if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ProfileViewController") as? ProfileViewController {
				controller.userDetailed = user
				self.navigationController?.pushViewController(controller, animated: true)
				FBoxHelper.getMainController()?.hideMenuButton(true)
			}
		})
	}
	
    // MARK: - Helper methods
    private func checkIndex() {
        guard let currentIndexPath = currentIndexPath else {return}
        if currentIndexPath.row != getCurrentIndexPath().row {
            self.currentIndexPath = getCurrentIndexPath()
        }
    }
    private func getCurrentIndexPath() -> NSIndexPath {
        let row = Int(collectionView.contentOffset.x / self.view.bounds.size.width)
        return NSIndexPath(forRow: row, inSection: 0)
    }
    private func getNextIndexPath() -> NSIndexPath? {
        let row = Int(collectionView.contentOffset.x / self.view.bounds.size.width)
        if row + 1 < users.count {
            return NSIndexPath(forRow: row + 1, inSection: 0)
        }else{
            return nil
        }
    }
    private func getPreviousIndexPath() -> NSIndexPath? {
        let row = Int(collectionView.contentOffset.x / self.view.bounds.size.width)
        if row > 0 {
            return NSIndexPath(forRow: row - 1, inSection: 0)
        }else{
            return nil
        }
    }
    
    // MARK: - UICollectionView
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if self.currentIndexPath == nil {
            self.currentIndexPath = indexPath
        }
        let collectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("SexyCollectionViewCell", forIndexPath: indexPath)
        if let sexyCollectionViewCell = collectionViewCell as? SexyCollectionViewCell {
            let user = self.users[indexPath.row]
            var imageUrl: String
            if let avatar = user.cryptedname {
                imageUrl = avatar.hasPrefix("http") ? avatar : FBNet.PROFILE_PIC_HIGH_RES + avatar
            }else{
                imageUrl = FBNet.PROFILE_DEFAULT_PIC
            }
            if let url = NSURL(string: imageUrl) {
                sexyCollectionViewCell.userImage.nk_cancelLoading()
                sexyCollectionViewCell.userImage.nk_setImageWith(url)
            }
            if indexPath.row + 1 < self.users.count {
                let nextUser = self.users[indexPath.row + 1]
                if let avatar = nextUser.cryptedname {
                    imageUrl = avatar.hasPrefix("http") ? avatar : FBNet.PROFILE_PIC_HIGH_RES + avatar
                }else{
                    imageUrl = FBNet.PROFILE_DEFAULT_PIC
                }
                if let url = NSURL(string: imageUrl) {
                    Nuke.taskWith(url).resume()
                }
            }
        }
        if self.needDownload && self.users.count > 0 && indexPath.row > self.users.count - 2 {
            self.loadPictures()
        }
        return collectionViewCell
    }
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let sexyCollectionViewCell = cell as? SexyCollectionViewCell {
            sexyCollectionViewCell.userImage.nk_cancelLoading()
        }
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return self.view.bounds.size
    }
    private var currentIndexPath: NSIndexPath? {
        didSet {
            guard let currentIndexPath = currentIndexPath else {return}
			self.usernameLabel.text = "\(self.users[currentIndexPath.row].uname), \(self.users[currentIndexPath.row].age)";
            let user = self.users[currentIndexPath.row]
            let temp = Double(user.averageVote) * 10.0
            if let yourVote = self.yourRates[user.picid] where yourVote > temp {
                self.temperatureView.temperature = yourVote
            }else{
                self.temperatureView.temperature = 50
            }
            if currentIndexPath.row == 0 {
                self.backButton.enabled = false
            }else{
                self.backButton.enabled = true
            }
            if currentIndexPath.row == self.users.count - 1 {
                self.forwardButton.enabled = false
            }else{
                self.forwardButton.enabled = true
            }
        }
    }
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.checkIndex()
    }
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        self.checkIndex()
    }
    
    // MARK: - TemperatureViewDelegate
    private var yourRates: [Int: Double] = [:]
    func temperatureChanged(temperature: Double) {
        guard let currentIndexPath = currentIndexPath else {return}
        let user = self.users[currentIndexPath.row]
        let vote = Int(round(temperature/10.0))
        yourRates[user.picid] = temperature
        GoogleAnalitics.send(GoogleAnalitics.SexyOrNot.Category, action: GoogleAnalitics.SexyOrNot.VOTE, label: nil, value: temperature)
        Net.rateRicture(String(user.picid), vote: vote)
		self.forwardAction(self);
    }
    func temperaturePressed(isPressed: Bool) {
        self.temperatureButtonImage.hidden = isPressed
        self.temperatureSeletedButtonImage.hidden = !isPressed
    }
}
