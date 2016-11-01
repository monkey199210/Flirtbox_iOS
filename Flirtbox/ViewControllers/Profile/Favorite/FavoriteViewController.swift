//
//  FavoriteViewController.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 08.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit
import LGAlertView

class FavoriteViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate {

    var user: FBSearchedUser?
    var userDetailed: FBUser?
    
    // MARK: - Lifecycle
    var active = false {
        didSet {
            if active {
                if self.faves.count > 0 {
                    self.profileViewController?.liftUp()
                }else{
                    self.profileViewController?.middleLift()
                }
            }
        }
    }
    var faves: Dictionary<String,Array<String>> = [:]
    weak var profileViewController: ProfileViewController?
    deinit {
        FBEvent.onProfileReceived().removeListener(self)
        FBEvent.onAuthenticated().removeListener(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.user == nil && self.userDetailed == nil {
            if AuthMe.isAuthenticated() {
                if let user = UserProfile.currentUser() {
                    configureWithUser(user)
                }
                FBEvent.onProfileReceived().listen(self, callback: { [unowned self] (user) -> Void in
                    self.configureWithUser(user)
                })
            }
            FBEvent.onAuthenticated().listen(self) { [unowned self] (isAuthenticated) -> Void in
                if isAuthenticated {
                    if let user = UserProfile.currentUser() {
                        self.configureWithUser(user, animated: false)
                    }
                }else{
                    self.hideCollection(false)
                }
            }
        }else{
            self.emptyButton.hidden = true
            self.emptyLAbel.hidden = true
            self.collectionView.hidden = true
            if let user = self.profileViewController?.userDetailed {
                configureWithUser(user)
            }
        }
    }
    func updateWithUser(user: FBUser) {
        configureWithUser(user)
    }
    private func configureWithUser(user: FBUser, animated: Bool = true) {
        if let fvs = user.favourites {
            if fvs.count > 0 {
                showCollection(fvs, animated: animated)
            }else{
                hideCollection(animated)
            }
        }else{
            hideCollection(animated)
        }
    }
    private func showCollection(faves: Dictionary<String,Array<String>>, animated: Bool = true) {
        self.faves = faves
        self.collectionView.hidden = false
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
        if active && animated {
            self.profileViewController?.liftUp()
        }
    }
    private func hideCollection(animated: Bool = true) {
        if !self.collectionView.hidden || self.faves.count > 0 {
            self.faves = [:]
            self.collectionView.reloadData()
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.hidden = true
            if active && animated {
                self.profileViewController?.middleLift()
            }
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var emptyButton: UIButton!
    @IBOutlet weak var emptyLAbel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Actions
    @IBAction func addFaveAction(sender: AnyObject) {
        if let profileVC = self.profileViewController {
            profileVC.openAddFaves()
        }
    }
    
    // MARK: - UICollectionView
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if user == nil {
            return CGSizeMake(self.collectionView.frame.size.height, 68)
        }else{
            return CGSizeZero
        }
    }
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: "TagsBottomCollectionReusableView", forIndexPath: indexPath) as! TagsBottomCollectionReusableView
		view.addFavoritesButton.setTitle(("_PROFILE_ADD_FAVORITES".localized).uppercaseString,forState: .Normal)
		
        return view
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if self.user == nil && self.userDetailed == nil {
            let key = Array(self.faves.keys.sort())[indexPath.row]
            let dave = self.faves[key]!.sort()
            if let profileVC = self.profileViewController {
                profileVC.openAddFaves(dave, category: key)
            }
        }
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return faves.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let collectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("FavesCollectionViewCell", forIndexPath: indexPath)
        if let favesCollectionViewCell = collectionViewCell as? FavesCollectionViewCell {
            for tagView in favesCollectionViewCell.tagsView.subviews {
                tagView.removeFromSuperview()
            }
            let key = Array(self.faves.keys.sort())[indexPath.row]
            favesCollectionViewCell.faveImage.image = FavoriteViewController.getImageForTag(key)
            let dave = self.faves[key]!.sort()
            var X: CGFloat = 5.0
            var Y: CGFloat = 0.0
            var size: CGSize = CGSizeZero
            var tagIndex = 0
            for tag in dave {
                if X + size.width + tagSpace() >= tagViewWidth() {
                    X = 0.0
                    Y += size.height + tagSpace()
                }
                size = getTagsFont().sizeOfString(tag, constrainedToWidth: Double(tagViewWidth()), constrainedToHeight: DBL_MAX)
                let tagLabel = UILabel(frame: CGRectMake(X, Y, size.width, size.height))
                tagLabel.numberOfLines = 0
                tagLabel.text = tag
                tagLabel.font = getTagsFont()
                tagLabel.textColor = UIColor.whiteColor()
                tagLabel.backgroundColor = UIColor.clearColor()
                favesCollectionViewCell.tagsView.addSubview(tagLabel)
                if X + size.width + tagSpace() >= tagViewWidth() {
                    X = 0.0
                    Y += size.height + tagSpace()
                    size = CGSizeZero
                }else{
                    X += size.width + tagSpace()
                }
                let bgImageView = UIImageView(frame: CGRectMake(tagLabel.frame.origin.x - 4, tagLabel.frame.origin.y - 4, tagLabel.frame.size.width + 8, tagLabel.frame.size.height + 8))
                bgImageView.image = UIImage(named: R.AssetsAssets.blueRounded.takeUnretainedValue() as String)
                favesCollectionViewCell.tagsView.insertSubview(bgImageView, belowSubview: tagLabel)
                
                let button = UIButton(type: .Custom)
                button.frame = bgImageView.frame
                button.tag = tagIndex
                button.titleLabel?.textColor = UIColor.clearColor()
                button.titleLabel?.text = key
                button.addTarget(self, action: #selector(FavoriteViewController.tagAction(_:)), forControlEvents: .TouchUpInside)
                favesCollectionViewCell.tagsView.addSubview(button)
                
                tagIndex += 1
            }
			let filtered = Net.faves.filter(){
				$0.tag == key.uppercaseString
			}
			favesCollectionViewCell.faveTitle.text = filtered.count != 0
													? filtered[0].title.uppercaseString
													: key.uppercaseString
        }
        return collectionViewCell
    }
    class func getImageForTag(tagCategory: String) -> UIImage? {
        var image: UIImage? = nil
        switch tagCategory.uppercaseString {
        case "SPORTS":
            image = UIImage(named: R.AssetsAssets.favesSport.takeUnretainedValue() as String)
        case "MUSIC":
            image = UIImage(named: R.AssetsAssets.favesMusic.takeUnretainedValue() as String)
        case "FOOD":
            image = UIImage(named: R.AssetsAssets.favesFood.takeUnretainedValue() as String)
        case "TRAVEL":
            image = UIImage(named: R.AssetsAssets.favesTravel.takeUnretainedValue() as String)
        default: break
        }
        return image
    }
    func tagAction(button: UIButton) {
        guard let key = button.titleLabel?.text where key.length > 0 else {return}
        let dave = self.faves[key]!.sort()
        let tag = dave[button.tag]
        if self.user != nil || self.userDetailed != nil {
            var needToSuggest = false
            if AuthMe.isAuthenticated() {
                if let user = UserProfile.currentUser() {
                    if let faves = user.favourites where faves.count > 0 {
                        if let myDave = faves[key] where myDave.count > 0 {
                            needToSuggest = true
                            for myTag in myDave {
                                if myTag == tag {
                                    needToSuggest = false
                                    break
                                }
                            }
                        }else{
                            needToSuggest = true
                        }
                    }else{
                        needToSuggest = true
                    }
                }
            }
            if needToSuggest {
                self.profileViewController?.suggestTag(tag, key: key)
            }
        }else{
            self.selectedTag = tag
            self.selectedKey = key
            let alert = UIAlertView(title: NSString(format: "_PROFILE_REMOVE_FAVORITES".localized, tag) as String , message: "", delegate: self, cancelButtonTitle: "_CANCEL".localized.uppercaseString, otherButtonTitles: "_YES".localized.uppercaseString)
            alert.show()
        }
    }
    private var selectedTag: String?
    private var selectedKey: String?
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.cancelButtonIndex != buttonIndex {
            if let tag = self.selectedTag, let key = self.selectedKey {
                var myTags: [String] = []
                if AuthMe.isAuthenticated() {
                    if let user = UserProfile.currentUser() {
                        if let faves = user.favourites where faves.count > 0 {
                            if let myDave = faves[key] where myDave.count > 0 {
                                myTags = myDave
                            }
                        }
                    }
                }
                if myTags.contains(tag) {
                    myTags = myTags.filter({ (value) -> Bool in
                        return value != tag
                    })
                    GoogleAnalitics.send(GoogleAnalitics.OwnFavorites.Category, action: GoogleAnalitics.OwnFavorites.REMOVE, label: key)
                    Net.updateProfile(key.uppercaseString, value: myTags)
                }
            }
        }
    }
	
    private func tagSpace() -> CGFloat {
        return 10
    }
    private func tagViewWidth() -> CGFloat {
        return self.view.frame.size.width - 70
    }
    private func getTagsFont() -> UIFont {
        return UIFont(name: "Roboto", size: 13)!
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let key = Array(self.faves.keys.sort())[indexPath.row]
        let dave = self.faves[key]!.sort()
        var X: CGFloat = 0.0
        var Y: CGFloat = 0.0
        var size: CGSize = CGSizeZero
        for tag in dave {
            if X + size.width + tagSpace() >= tagViewWidth() {
                X = 0.0
                Y += size.height + tagSpace()
            }
            size = getTagsFont().sizeOfString(tag, constrainedToWidth: Double(tagViewWidth()), constrainedToHeight: DBL_MAX)
            if X + size.width + tagSpace() >= tagViewWidth() {
                X = 0.0
                Y += size.height + tagSpace()
                size = CGSizeZero
            }else{
                X += size.width + tagSpace()
            }
        }
        Y += size.height + tagSpace()
        return CGSizeMake(self.collectionView.frame.size.width, 45 + Y + 15)
    }
}
