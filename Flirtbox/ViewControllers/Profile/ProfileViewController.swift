//
//  ProfileViewController.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 06.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit
import MobileCoreServices

protocol OnlineControllerDelegate{
	func refreshData();
}

class ProfileViewController: CPopViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
	var onlineDelegate : OnlineControllerDelegate?
    var user: FBSearchedUser?
    var userDetailed: FBUser? {
        didSet {
            if let user = userDetailed {
                fave?.updateWithUser(user)
                about?.updateWithUser(user)
                question?.updateWithUser(user)
            }
        }
    }
    
    private let kDefaultPhotoMenuHeight: CGFloat = 180.0
    
    deinit {
        self.fave = nil
        self.about = nil
        self.question = nil
        FBEvent.onMainPictChanged().removeListener(self)
        FBEvent.onProfileReceived().removeListener(self)
        FBEvent.onAuthenticated().removeListener(self)
        FBEvent.onPicturesChanged().removeListener(self)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.blockView.alpha = 0.0
        self.editImagesButton.enabled = false
        uploadAlert.alpha = 0.0
        selectedLine.alpha = 0.0
        self.myImageBlur.alpha = 0.0
        self.userLocation.text = " "
        self.nameWithAge.text = " "
        self.locationImage.hidden = true
        self.downButton.userInteractionEnabled = false
        self.dislikeButton.hidden = true
        self.likeButton.hidden = true
        if user == nil && userDetailed == nil {
			self.favouritesButton.hidden = true;
            self.pageControl.hidden = true
            self.userImagesCollectionView.hidden = true
            self.photoMenu.hidden = true
            self.backButton.hidden = true
            self.backButtonImage.hidden = true
            self.topDotsButton.hidden = true
            self.topSettingsButton.hidden = true
            
            self.updateMainImage()
            FBEvent.onMainPictChanged().listen(self) { [unowned self] (_) -> Void in
                self.updateMainImage()
            }
            
            if AuthMe.isAuthenticated() {
                self.configure()
            }
            FBEvent.onAuthenticated().listen(self) { [unowned self] (isAuthenticated) -> Void in
                if isAuthenticated {
                    self.configure()
                }else{
                    self.down()
                    self.nameWithAge.text = " "
                    self.userLocation.text = " "
                    self.locationImage.hidden = true
                    self.images.removeAll()
                    self.pageControl.hidden = true
                    self.userImagesCollectionView.reloadData()
                    self.userImagesCollectionView.collectionViewLayout.invalidateLayout()
                    self.myImage.image = nil
                    self.checkForImages()
                }
            }
        }else{
            self.pageControl.hidden = true
            self.userImagesCollectionView.hidden = false
            self.photoMenu.hidden = false
            self.photoMenuHeight.constant = 0.0
            self.editImagesButton.hidden = true
            self.backButton.hidden = false
            self.backButtonImage.hidden = false
            self.uploadBtn.hidden = true
            self.uploadAlert.hidden = true
            self.myImageBlur.hidden = false
            self.photosViewHeight.constant = 0.0
            bottomConstraint.constant = -kimagesHeight
            self.topTitle.text = "Online"
            if userDetailed == nil {
                self.nameWithAge.text = user!.username + ", " + String(user!.age)
                self.profileActivity.startAnimating()
                Net.userData(user!.username).onSuccess(callback: { (user) -> Void in
                    self.profileActivity.stopAnimating()
                    self.configureWithUser(user)
                }).onFailure(callback: { (_) -> Void in
                    self.profileActivity.stopAnimating()
                })
            }else{
                self.topSettingsButton.hidden = true
                if userDetailed!.general.age != nil {
                    self.nameWithAge.text = userDetailed!.general.username + ", " + userDetailed!.general.age!
                }else{
                    self.nameWithAge.text = userDetailed!.general.username
                }
                self.configureWithUser(userDetailed!)
            }
        }
		self.blockUserButton.setTitle("_BLOCK".localized, forState: .Normal);
		self.shareButton.setTitle("_SHARE".localized, forState: .Normal);
		self.reportUserButton.setTitle("_REPORT".localized, forState: .Normal);
        self.view.layoutIfNeeded()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProfileViewController.keyboardWillChangeFrame(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProfileViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
		self.onlineDelegate?.refreshData();
    }
    func keyboardWillChangeFrame(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            yCenterConstraint?.constant = -keyboardSize.height/2.0
            UIView.animateWithDuration(FBoxConstants.kAnimationDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
                self.view.layoutIfNeeded()
                }, completion:{(_) -> Void in
            })
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        yCenterConstraint?.constant = 0.0
        UIView.animateWithDuration(FBoxConstants.kAnimationDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion:{(_) -> Void in
                
        })
    }
    private func updateMainImage() {
        UserProfile.getMainPict({ (image) -> Void in
            if self.myImage.image == nil {
                self.myImage.image = image
            }
            self.checkForImages()
        })
    }
    // MARK: - Outlets
    @IBOutlet weak var profileActivity: UIActivityIndicatorView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var downButton: UIButton!
    @IBOutlet weak var userImagesCollectionView: UICollectionView!
    @IBOutlet weak var blockUserButton: UIButton!
    @IBOutlet weak var reportUserButton: UIButton!
    @IBOutlet weak var favouritesButton: UIButton!
    @IBOutlet weak var photoMenuHeight: NSLayoutConstraint!
    @IBOutlet weak var photoMenu: UIView!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var topTitle: UILabel!
    @IBOutlet weak var backButtonImage: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var blockView: UIView!
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var userLocation: UILabel!
    @IBOutlet weak var nameWithAge: UILabel!
    @IBOutlet weak var editImagesButton: UIButton!
    @IBOutlet weak var topDotsButton: UIButton!
    @IBOutlet weak var topSettingsButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var uploadAlert: UIView!
    @IBOutlet weak var myImageBlur: UIView!
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var bottomHeight: NSLayoutConstraint!
    @IBOutlet weak var topHeight: NSLayoutConstraint!
    @IBOutlet weak var selectedLeft: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var photosViewHeight: NSLayoutConstraint!
    @IBOutlet weak var selectedLine: UIImageView!
	@IBOutlet weak var shareButton: UIButton!
    // MARK: - Actions
	@IBAction func shareAction(sender: AnyObject) {
		print("share button tapped");
	}
    @IBAction func blockUserAction(sender: AnyObject) {
        if let user = self.userDetailed {
            if let blocked = user.connections?.isBlocked where blocked {
                GoogleAnalitics.send(GoogleAnalitics.OthersProfile.Category, action: GoogleAnalitics.OthersProfile.UNBLOCK)
                Net.userAction(user.general.username, action: .Unblock)
                self.blockUserButton.selected = false
				userDetailed?.connections?.isBlocked = false;
            }else{
                GoogleAnalitics.send(GoogleAnalitics.OthersProfile.Category, action: GoogleAnalitics.OthersProfile.BLOCK)
                Net.userAction(user.general.username, action: .Block)
                self.blockUserButton.selected = true
				userDetailed?.connections?.isBlocked = true;
            }
        }
        closePhotoMenu()
    }
    @IBAction func reportAction(sender: AnyObject) {
        closePhotoMenu()
        if let reportViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ReportViewController") as? ReportViewController {
            reportViewController.willMoveToParentViewController(self)
            reportViewController.profileViewController = self
            self.addChildViewController(reportViewController)
            reportViewController.view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(reportViewController.view)
            reportViewController.didMoveToParentViewController(self)

            Restraint(reportViewController.view, .CenterX, .Equal, self.view, .CenterX).addToView(self.view)
            yCenterConstraint = Restraint(reportViewController.view, .CenterY, .Equal, self.view, .CenterY).addToView(self.view)
            Restraint(reportViewController.view, .Width,  .Equal, 300).addToView(reportViewController.view)
            Restraint(reportViewController.view, .Height,  .Equal, 200).addToView(reportViewController.view)
            
            UIView.appearWithScale(reportViewController.view, duration: FBoxConstants.kAnimationFastDuration, completition: {
                reportViewController.openReportText()
            })
            FBoxHelper.getMainController()?.hideMenuButton(false)
            UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
                self.blockView.alpha = 1.0
                }, completion:nil)
        }
    }
    @IBAction func addToFavouritesAction(sender: AnyObject) {
        if let user = self.userDetailed {
            if let fave = user.connections?.isFavourite where fave {
                GoogleAnalitics.send(GoogleAnalitics.OthersProfile.Category, action: GoogleAnalitics.OthersProfile.REMOVE_FAVORITE)
                Net.userAction(user.general.username, action: .RemoveFavourite)
                self.favouritesButton.selected = false
				userDetailed?.connections?.isFavourite = false;
            }else{
                GoogleAnalitics.send(GoogleAnalitics.OthersProfile.Category, action: GoogleAnalitics.OthersProfile.FAVORITE)
                Net.userAction(user.general.username, action: .AddFavourite)
                self.favouritesButton.selected = true
				userDetailed?.connections?.isFavourite = true;
            }
        }
        closePhotoMenu()
    }
    @IBAction func blockAction(sender: AnyObject) {
        closePhotoMenu()
    }
    private func closePhotoMenu() {
        if self.photoMenuHeight.constant != 0.0 {
            self.photoMenuHeight.constant = 0.0
            UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.blockView.alpha = 0.0
                }, completion:nil)
        }
    }
    @IBAction func likeAction(sender: AnyObject) {
        if let user = self.userDetailed {
            GoogleAnalitics.send(GoogleAnalitics.OthersProfile.Category, action: GoogleAnalitics.OthersProfile.YES)
            Net.userAction(user.general.username, action: .WantToMeet)
			self.userDetailed?.connections?.isFavourite = true;
            //self.dislikeButton.hidden = false
            //self.likeButton.hidden = true
        }
    }
    @IBAction func dislikeAction(sender: AnyObject) {
        if let user = self.userDetailed {
            GoogleAnalitics.send(GoogleAnalitics.OthersProfile.Category, action: GoogleAnalitics.OthersProfile.NO)
            Net.userAction(user.general.username, action: .RemoveWantToMeet)
			self.userDetailed?.connections?.isFavourite = false;
            //self.dislikeButton.hidden = true
            //self.likeButton.hidden = false
        }
    }
    @IBAction func userActions(sender: AnyObject) {
        self.photoMenuHeight.constant = kDefaultPhotoMenuHeight
        UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.blockView.alpha = 1.0
            }, completion:nil)
    }
    @IBAction func chatAction(sender: AnyObject) {
        if let chatViewController = UIStoryboard(name: "Messages", bundle: nil).instantiateViewControllerWithIdentifier("ChatViewController") as? ChatViewController {
            var isContactable = true
            if let user = self.userDetailed, let contactPossible = user.connections?.contactPossible {
                isContactable = contactPossible
            }
            if isContactable {
                GoogleAnalitics.send(GoogleAnalitics.OthersProfile.Category, action: GoogleAnalitics.OthersProfile.CONVERSATION)
                chatViewController.user = self.user
                self.navigationController?.pushViewController(chatViewController, animated: true)
            }else{
                GoogleAnalitics.send(GoogleAnalitics.OthersProfile.Category, action: GoogleAnalitics.OthersProfile.NOT_CONTACTABLE)
                UIAlertView(title: "You can not contact this member", message: "", delegate: nil, cancelButtonTitle: "OK").show()
            }
        }
    }
    @IBAction func backAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func editImagesAction(sender: AnyObject) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("EditImageViewController")
        self.presentViewController(controller, animated: true, completion: nil)
    }
    @IBAction func downAction(sender: AnyObject) {
        selectedLine.alpha = 0.0
        down()
    }
    
    @IBAction func bgDownAction(sender: AnyObject) {
        selectedLine.alpha = 0.0
        down()
    }
    
    @IBAction func uploadPhotoAction(sender: AnyObject) {
        openActionSheet()
    }
    
    @IBAction func questionsAction(sender: AnyObject) {
        if self.isProfileVisible {
            selectedLine.alpha = 1.0
            selectedLeft.constant = 2 * self.view.frame.size.width / 3.0
            liftUp()
            addQuestion()
            self.fave?.active = false
        }else{
            profileDisabled()
        }
    }
    @IBAction func faveAction(sender: AnyObject) {
        if self.isProfileVisible {
            selectedLine.alpha = 1.0
            selectedLeft.constant = self.view.frame.size.width / 3.0
            if let faves = self.fave {
                if faves.faves.count > 0 {
                    liftUp()
                }else{
                    middleLift()
                }
            }
            addFave()
            self.fave?.active = true
        }else{
            profileDisabled()
        }
    }
    @IBAction func aboutAction(sender: AnyObject) {
        if self.isProfileVisible {
            selectedLine.alpha = 1.0
            selectedLeft.constant = 0.0
            liftUp()
            addAbout()
            self.fave?.active = false
        }else{
            profileDisabled()
        }
    }
    private func profileDisabled() {
        UIAlertView(title: "This profile is not visible to you", message: "", delegate: nil, cancelButtonTitle: "OK").show()
    }
    @IBAction func openUploadAlertAction(sender: AnyObject) {
        UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.uploadAlert.alpha = 1.0
            }, completion:nil)
    }
    @IBAction func closeUploadAlertAction(sender: AnyObject) {
        closeUploadAlert()
    }
    
    // MARK: - Helper methods
    private let kWidthScale: CGFloat = 280.0/320.0
    private let kHeightScale: CGFloat = 594.0/846.0
    private var selectedTag: String?
    private var selectedKey: String?
    func suggestTag(tag: String, key: String) {
        selectedTag = tag
        selectedKey = key
        let width = self.view.frame.size.width * kWidthScale
        let height = width * kHeightScale
        let suggestPopUp = UIView(frame: CGRectMake(0, 0, width, height))
        suggestPopUp.backgroundColor = UIColor.clearColor()
        let imageView = UIImageView(image: UIImage(named: "roundedWhite"))
        suggestPopUp.addSubview(imageView)
        Restraint(imageView, .Top, .Equal, suggestPopUp, .Top).addToView(suggestPopUp)
        Restraint(imageView, .Bottom, .Equal, suggestPopUp, .Bottom).addToView(suggestPopUp)
        Restraint(imageView, .Leading, .Equal, suggestPopUp, .Leading).addToView(suggestPopUp)
        Restraint(imageView, .Trailing, .Equal, suggestPopUp, .Trailing).addToView(suggestPopUp)
        let marginConst: CGFloat = 20.0
        let littleMarginConst: CGFloat = 10.0
        var topLabel: UILabel
        if let image = FavoriteViewController.getImageForTag(key) {
            let iconView = UIImageView(image: image)
            suggestPopUp.addSubview(iconView)
            Restraint(iconView, .Top, .Equal, suggestPopUp, .Top, 1.0, marginConst).addToView(suggestPopUp)
            Restraint(iconView, .Leading, .Equal, suggestPopUp, .Leading, 1.0, marginConst).addToView(suggestPopUp)
            topLabel = UILabel(frame: CGRectZero)
            let font = UIFont(name: "Roboto-Medium", size: 17.0)
            topLabel.font = font
            topLabel.text = tag
            topLabel.textColor = UIColor(red:0.38, green:0.38, blue:0.38, alpha:1)
            suggestPopUp.addSubview(topLabel)
            Restraint(topLabel, .CenterY, .Equal, iconView, .CenterY).addToView(suggestPopUp)
            Restraint(topLabel, .Leading, .Equal, iconView, .Trailing, 1.0, littleMarginConst).addToView(suggestPopUp)
            Restraint(suggestPopUp, .Trailing, .GreaterThanOrEqual, topLabel, .Trailing, 1.0, marginConst).addToView(suggestPopUp)
        }else{
            topLabel = UILabel(frame: CGRectZero)
            let font = UIFont(name: "Roboto-Medium", size: 17.0)
            topLabel.font = font
            topLabel.text = tag
            topLabel.textColor = UIColor(red:0.38, green:0.38, blue:0.38, alpha:1)
            suggestPopUp.addSubview(topLabel)
            Restraint(topLabel, .Top, .Equal, suggestPopUp, .Top, 1.0, marginConst).addToView(suggestPopUp)
            Restraint(topLabel, .Leading, .Equal, suggestPopUp, .Leading, 1.0, marginConst).addToView(suggestPopUp)
            Restraint(suggestPopUp, .Trailing, .GreaterThanOrEqual, topLabel, .Trailing, 1.0, marginConst).addToView(suggestPopUp)
        }
        let buttonsHeight: CGFloat = 40.0
        let label = UILabel(frame: CGRectZero)
        let font = UIFont(name: "Roboto", size: 14.0)
        label.font = font
        let attribute = [NSFontAttributeName: UIFont(name: "Roboto", size: 14.0)!]
        let attributeBolt = [NSFontAttributeName: UIFont(name: "Roboto-Medium", size: 14.0)!]
        let suggestionTextFirst = NSMutableAttributedString(string: "Do you also like ", attributes: attribute)
        let suggestionTextTag = NSAttributedString(string: "\(tag)", attributes: attributeBolt)
        suggestionTextFirst.appendAttributedString(suggestionTextTag)
        let suggestionTextSecond = NSMutableAttributedString(string: "? Do you want add it in your favorites?", attributes: attribute)
        suggestionTextFirst.appendAttributedString(suggestionTextSecond)
        label.attributedText = suggestionTextFirst
        label.textColor = UIColor(red:0.38, green:0.38, blue:0.38, alpha:1)
        label.numberOfLines = 0
        suggestPopUp.addSubview(label)
        Restraint(label, .Top, .Equal, topLabel, .Bottom, 1.0, marginConst).addToView(suggestPopUp)
        Restraint(label, .Leading, .Equal, suggestPopUp, .Leading, 1.0, marginConst).addToView(suggestPopUp)
        Restraint(suggestPopUp, .Trailing, .GreaterThanOrEqual, label, .Trailing, 1.0, marginConst).addToView(suggestPopUp)
        Restraint(suggestPopUp, .Bottom, .GreaterThanOrEqual, label, .Bottom, 1.0, 2 * littleMarginConst + buttonsHeight).addToView(suggestPopUp)
        
        let buttonYes = UIButton(type: .Custom)
        buttonYes.setTitleColor(UIColor(red:0.32, green:0.73, blue:0.97, alpha:1), forState: .Normal)
        buttonYes.setTitle("YES", forState: .Normal)
        buttonYes.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 17.0)
        buttonYes.addTarget(self, action: #selector(ProfileViewController.addTag(_:)), forControlEvents: .TouchUpInside)
        suggestPopUp.addSubview(buttonYes)
        Restraint(suggestPopUp, .Trailing, .Equal, buttonYes, .Trailing, 1.0, littleMarginConst).addToView(suggestPopUp)
        Restraint(suggestPopUp, .Bottom, .Equal, buttonYes, .Bottom, 1.0, littleMarginConst).addToView(suggestPopUp)
        Restraint(buttonYes, .Width,  .Equal, 50.0).addToView(suggestPopUp)
        Restraint(buttonYes, .Height,  .Equal, buttonsHeight).addToView(suggestPopUp)
        
        let buttonCancel = UIButton(type: .Custom)
        buttonCancel.setTitleColor(UIColor(red:0.32, green:0.73, blue:0.97, alpha:1), forState: .Normal)
        buttonCancel.setTitle("CANCEL", forState: .Normal)
        buttonCancel.titleLabel?.font = UIFont(name: "Roboto", size: 17.0)
        buttonCancel.addTarget(self, action: #selector(ProfileViewController.cancelTag(_:)), forControlEvents: .TouchUpInside)
        suggestPopUp.addSubview(buttonCancel)
        Restraint(buttonYes, .Leading, .Equal, buttonCancel, .Trailing, 1.0, littleMarginConst).addToView(suggestPopUp)
        Restraint(suggestPopUp, .Bottom, .Equal, buttonCancel, .Bottom, 1.0, littleMarginConst).addToView(suggestPopUp)
        Restraint(buttonCancel, .Width,  .Equal, 100.0).addToView(suggestPopUp)
        Restraint(buttonCancel, .Height,  .Equal, buttonsHeight).addToView(suggestPopUp)
        
        self.showCustomPopUp(suggestPopUp)
    }
    @objc private func addTag(button: UIButton) {
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
            myTags.append(tag)
            Net.updateProfile(key.uppercaseString, value: myTags)
        }
        self.closeCustomPopUp()
    }
    @objc private func cancelTag(button: UIButton) {
        self.closeCustomPopUp()
    }
    private func configure() {
        getImages()
        FBEvent.onPicturesChanged().listen(self) { [unowned self] (_) -> Void in
            self.images.removeAll()
            self.myImage.image = nil
            self.checkForImages()
            self.collectionView.reloadData()
            self.getImages()
        }
        if let user = UserProfile.currentUser() {
            configureWithUser(user)
        }
        FBEvent.onProfileReceived().listen(self, callback: { [unowned self] (user) -> Void in
            self.configureWithUser(user)
            FBEvent.onProfileReceived().removeListener(self)
        })
    }
    private func configureWithUser(user: FBUser) {
		if(user.general == nil)
		{
			return;
		}
        if let fave = user.connections?.isFavourite where fave {
            self.favouritesButton.selected = true
        }else{
            self.favouritesButton.selected = false
        }
        if let blocked = user.connections?.isBlocked where blocked {
            self.blockUserButton.selected = true
        }else{
            self.blockUserButton.selected = false
        }
        self.locationImage.hidden = false
        if user.general?.age != nil {
            self.nameWithAge.text = user.general.username + ", " + user.general.age!
        }else{
            self.nameWithAge.text = user.general.username
        }
        if user.general?.country.length > 0 && user.general.town?.length > 0 {
            self.userLocation.text = user.general.country + ", " + user.general.town!
        }else if user.general?.country.length == 0 && user.general.town?.length > 0 {
            self.userLocation.text = user.general.town
        }else if user.general?.country.length > 0 && user.general?.town?.length == 0 {
            self.userLocation.text = user.general.country
        }else{
            self.userLocation.text = " "
            self.locationImage.hidden = true
        }
        if self.user != nil || self.userDetailed != nil {
            GoogleAnalitics.send(GoogleAnalitics.OthersProfile.Category, action: GoogleAnalitics.OthersProfile.VIEW)
            self.dislikeButton.hidden = false
            self.likeButton.hidden = false
            if let wantToMeet = user.connections?.wantToMeet where wantToMeet {
                //self.dislikeButton.hidden = false
                //self.likeButton.hidden = true
            }else{
                //self.dislikeButton.hidden = true
                //self.likeButton.hidden = false
            }
            self.userDetailed = user
            self.userImages.removeAll()
            var isProfileVisible = true
            if let pvisible = user.connections?.profileVisible {
                isProfileVisible = pvisible
            }
            if isProfileVisible {
                if let photoRequesred = user.connections?.requiresPhoto where photoRequesred && !UserProfile.isIHavePhoto() {
                    UIAlertView(title: "Please upload a photo first", message: "", delegate: nil, cancelButtonTitle: "OK").show()
                    isProfileVisible = false
                }
            }else{
                GoogleAnalitics.send(GoogleAnalitics.OthersProfile.Category, action: GoogleAnalitics.OthersProfile.NOT_VISIBLE)
            }
            self.isProfileVisible = isProfileVisible
            if let pictures = user.pictures where pictures.count > 0 && isProfileVisible {
                self.userImagesCollectionView.hidden = false
                for picture in pictures {
                    self.userImages.append(picture)
                }
            }else{
                self.myImage.image = user.general.gender == "m" ? UIImage(named: "ic_man_placeholder_300dp") : UIImage(named: "ic_woman_placeholder_300dp")
                self.userImagesCollectionView.hidden = true
            }
            self.pageControl.numberOfPages = self.userImages.count
            self.pageControl.currentPage = 0
            if self.userImages.count < 2 {
                self.pageControl.hidden = true
            }else{
                self.pageControl.hidden = false
            }
            self.userImagesCollectionView.reloadData()
        }else{
            //autoupdate
            Net.settings(false).onSuccess { (settings) -> Void in
                for settings in settings.settings {
                    if settings.name == SettingsName.PrefLocationUpdate.rawValue {
                        LocationManager.sharedInstance.checkAutoupdate(settings.active)
                        break
                    }
                }
            }
        }
    }
    private var isProfileVisible = true
    private var pictures: [FBPicture] = []
    private func getImages(){
        UserProfile.images { (image, order) -> Void in
            self.insertImage(image, oder: order)
        }.onSuccess { (pictures) -> Void in
            self.pictures = pictures
            self.collectionView.reloadData()
        }
        LoadingImage.images { (loadingImage) -> Void in
            self.insertImage(loadingImage.image, oder: loadingImage.order)
        }
    }
    private func closeUploadAlert(){
        UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.uploadAlert.alpha = 0.0
            }, completion:nil)
    }
    
    var about: AboutMeViewController?
    private func addAbout() {
        if about == nil {
            if let aboutMeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("AboutMeViewController") as? AboutMeViewController {
                about = aboutMeViewController
                aboutMeViewController.user = self.user
                aboutMeViewController.userDetailed = self.userDetailed
                aboutMeViewController.profileViewController = self
                aboutMeViewController.willMoveToParentViewController(self)
                self.addChildViewController(aboutMeViewController)
                aboutMeViewController.view.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(aboutMeViewController.view)
                aboutMeViewController.didMoveToParentViewController(self)
                contentView.addConstraint(NSLayoutConstraint(item: aboutMeViewController.view, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1.0, constant: 0.0))
                contentView.addConstraint(NSLayoutConstraint(item: aboutMeViewController.view, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
                contentView.addConstraint(NSLayoutConstraint(item: aboutMeViewController.view, attribute: .Leading, relatedBy: .Equal, toItem: contentView, attribute: .Leading, multiplier: 1.0, constant: 0.0))
                contentView.addConstraint(NSLayoutConstraint(item: aboutMeViewController.view, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
            }
        }else{
            about?.view.hidden = false
            fave?.view.hidden = true
            question?.view.hidden = true
        }
    }
    var fave: FavoriteViewController?
    private func addFave() {
        if fave == nil {
            if let favoriteViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("FavoriteViewController") as? FavoriteViewController {
                fave = favoriteViewController
                favoriteViewController.profileViewController = self
                favoriteViewController.user = self.user
                favoriteViewController.userDetailed = self.userDetailed
                favoriteViewController.willMoveToParentViewController(self)
                self.addChildViewController(favoriteViewController)
                favoriteViewController.view.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(favoriteViewController.view)
                favoriteViewController.didMoveToParentViewController(self)
                contentView.addConstraint(NSLayoutConstraint(item: favoriteViewController.view, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1.0, constant: 0.0))
                contentView.addConstraint(NSLayoutConstraint(item: favoriteViewController.view, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
                contentView.addConstraint(NSLayoutConstraint(item: favoriteViewController.view, attribute: .Leading, relatedBy: .Equal, toItem: contentView, attribute: .Leading, multiplier: 1.0, constant: 0.0))
                contentView.addConstraint(NSLayoutConstraint(item: favoriteViewController.view, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
            }
        }else{
            about?.view.hidden = true
            fave?.view.hidden = false
            question?.view.hidden = true
        }
    }
    private var yCenterConstraint: NSLayoutConstraint?
    func openAddFaves(faves: Array<String> = [], category: String? = nil) {
        if let addFaveViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("AddFaveViewController") as? AddFaveViewController {
            addFaveViewController.willMoveToParentViewController(self)
            addFaveViewController.profileViewController = self
            self.addChildViewController(addFaveViewController)
            addFaveViewController.view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(addFaveViewController.view)
            addFaveViewController.didMoveToParentViewController(self)
            addFaveViewController.selectedTags = faves
            addFaveViewController.category = category
            Restraint(addFaveViewController.view, .CenterX, .Equal, self.view, .CenterX).addToView(self.view)
            yCenterConstraint = Restraint(addFaveViewController.view, .CenterY, .Equal, self.view, .CenterY).addToView(self.view)
            Restraint(addFaveViewController.view, .Width,  .Equal, 300).addToView(addFaveViewController.view)
            Restraint(addFaveViewController.view, .Height,  .Equal, 225).addToView(addFaveViewController.view)
            
            UIView.appearWithScale(addFaveViewController.view, duration: FBoxConstants.kAnimationFastDuration, completition: {
                addFaveViewController.openTags()
            })
            FBoxHelper.getMainController()?.hideMenuButton(false)
            UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
                self.blockView.alpha = 1.0
                }, completion:nil)
        }
    }
    func closeAddFave() {
        if user == nil && userDetailed == nil {
            FBoxHelper.getMainController()?.showMenuButton(true)
        }
        UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.blockView.alpha = 0.0
            }, completion:nil)
    }
    var question: QuestionsViewController?
    private func addQuestion() {
        if question == nil {
            if let questionsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("QuestionsViewController") as? QuestionsViewController {
                question = questionsViewController
                questionsViewController.user = self.user
                questionsViewController.userDetailed = self.userDetailed
                questionsViewController.profileViewController = self
                questionsViewController.willMoveToParentViewController(self)
                self.addChildViewController(questionsViewController)
                questionsViewController.view.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(questionsViewController.view)
                questionsViewController.didMoveToParentViewController(self)
                contentView.addConstraint(NSLayoutConstraint(item: questionsViewController.view, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1.0, constant: 0.0))
                contentView.addConstraint(NSLayoutConstraint(item: questionsViewController.view, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
                contentView.addConstraint(NSLayoutConstraint(item: questionsViewController.view, attribute: .Leading, relatedBy: .Equal, toItem: contentView, attribute: .Leading, multiplier: 1.0, constant: 0.0))
                contentView.addConstraint(NSLayoutConstraint(item: questionsViewController.view, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
            }
        }else{
            about?.view.hidden = true
            fave?.view.hidden = true
            question?.view.hidden = false
        }
    }
    let kimagesHeight: CGFloat = 75
    func liftUp() {
        photosViewHeight.constant = 0.0
        bottomConstraint.constant = self.view.frame.size.height - topHeight.constant - bottomHeight.constant - 20
        UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.uploadBtn.alpha = 0.0
            self.myImageBlur.alpha = 1.0
            }, completion:{ _ -> Void in
                self.downButton.userInteractionEnabled = true
        })
    }
    let kMiddleLiftConstant: CGFloat = 200.0
    func middleLift() {
        if user == nil && userDetailed == nil {
            photosViewHeight.constant = kimagesHeight
        }
        bottomConstraint.constant = kMiddleLiftConstant
        UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.uploadBtn.alpha = 0.0
            self.myImageBlur.alpha = 0.5
            self.view.layoutIfNeeded()
            }, completion:{ _ -> Void in
                self.downButton.userInteractionEnabled = true
        })
    }
    private func down() {
        if user == nil && userDetailed == nil {
            photosViewHeight.constant = kimagesHeight
            bottomConstraint.constant = 0.0
        }else{
            bottomConstraint.constant = -kimagesHeight
        }
        UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.uploadBtn.alpha = 1.0
            self.myImageBlur.alpha = 0.0
            }, completion:{ _ -> Void in
                self.downButton.userInteractionEnabled = false
        })
    }
    
    func checkForImages() {
        if myImage.image != nil {
            self.uploadBtn.hidden = true
            self.uploadAlert.hidden = true
            self.myImageBlur.hidden = false
        }else{
            self.uploadBtn.hidden = false
            self.uploadAlert.hidden = false
            self.myImageBlur.hidden = true
        }
    }
    
    func insertImage(image: UIImage, oder: String) {
        var contains = false
        for img in self.images {
            if img.image == image || img.order == Int(oder)! {
                contains = true
                break
            }
        }
        if !contains {
            images.append((image, Int(oder)!))
            images.sortInPlace({ (first, second) -> Bool in
                return first.order > second.order
            })
            collectionView.reloadData()
        }
    }
    func openActionSheet(){
        let actionsheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Choose Photo", "Take Photo")
        actionsheet.showInView(self.view)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    private var justAddedImages: [String] = []
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let fixedImage = fixImageOrientation(image)
            let resizedImage = fixedImage.resizeToWidth(FBoxHelper.getScreenSize().width)
            let loadingImage = UserProfile.uploadImage(resizedImage)
            justAddedImages.append(loadingImage.order)
            myImage.image = loadingImage.image
            insertImage(loadingImage.image, oder: loadingImage.order)
            checkForImages()
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
        closeUploadAlert()
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        closeUploadAlert()
    }
    
    // MARK: - UIActionSheetDelegate
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex > 0 {
            var isAvailable = false
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.mediaTypes = [kUTTypeImage as String]
            if buttonIndex == 1 && UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum){
                imagePicker.sourceType = .SavedPhotosAlbum
                isAvailable = true
            }else if(UIImagePickerController.isSourceTypeAvailable(.Camera)){
                imagePicker.sourceType = .Camera
                imagePicker.cameraDevice = .Front
                isAvailable = true
            }
            if isAvailable {
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - UICollectionView
    private var images: [(image: UIImage,order: Int)] = [] {
        didSet {
            self.editImagesButton.enabled = images.count > 0
        }
    }
    private var userImages: [FBPicture] = []
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return images.count + 1
        }else{
            return userImages.count
        }
    }
    private let kEmptyDateString = "0000-00-00 00:00:00"
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            let collectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("ProfileImageCollectionViewCell", forIndexPath: indexPath)
            if let profileImageCollectionViewCell = collectionViewCell as? ProfileImageCollectionViewCell {
                if indexPath.row == 0 {
                    profileImageCollectionViewCell.sandclockIcon.hidden = true
                    profileImageCollectionViewCell.blur.hidden = true
                    profileImageCollectionViewCell.profileImage.image = UIImage(named: "profileGetPhoto")
                }else{
                    let img = images[indexPath.row - 1].image
                    let order = images[indexPath.row - 1].order
                    if self.pictures.count > indexPath.row - 1 {
                        let picture = self.pictures[indexPath.row - 1]
                        if picture.approvedwhen == kEmptyDateString {
                            profileImageCollectionViewCell.sandclockIcon.hidden = false
                            profileImageCollectionViewCell.blur.hidden = false
                        }else{
                            profileImageCollectionViewCell.sandclockIcon.hidden = true
                            profileImageCollectionViewCell.blur.hidden = true
                        }
                    }else{
                        if justAddedImages.contains(String(order)) {
                            profileImageCollectionViewCell.sandclockIcon.hidden = false
                            profileImageCollectionViewCell.blur.hidden = false
                        }else{
                            profileImageCollectionViewCell.sandclockIcon.hidden = true
                            profileImageCollectionViewCell.blur.hidden = true
                        }
                    }
                    profileImageCollectionViewCell.profileImage.image = img
                }
            }
            return collectionViewCell
        }else{
            let collectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("UserImageCollectionViewCell", forIndexPath: indexPath)
            if let userImageCollectionViewCell = collectionViewCell as? UserImageCollectionViewCell {
                userImageCollectionViewCell.userImage.nk_cancelLoading()
                if (String(Visibility.MembersWithPhoto.rawValue) == userImages[indexPath.row].visibility && !UserProfile.isIHavePhoto()) || !self.isProfileVisible {
                    userImageCollectionViewCell.emptyLbl.hidden = false
                }else{
                    userImageCollectionViewCell.emptyLbl.hidden = true
                    let urlString = userImages[indexPath.row].getUrl()
                    if let url = NSURL(string: urlString) {
                        userImageCollectionViewCell.userImage.nk_setImageWith(url)
                    }
                }
            }
            return collectionViewCell
        }
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == self.collectionView {
            if indexPath.row == 0 {
                openActionSheet()
            }else{
                myImage.image = images[indexPath.row - 1].image
                checkForImages()
            }
        }
    }
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == self.userImagesCollectionView {
            var page: Int = Int(scrollView.contentOffset.x / self.view.frame.size.width)
            page = min(page, self.userImages.count - 1)
            page = max(page, 0)
            self.pageControl.currentPage = page
        }
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if collectionView == self.collectionView {
            return CGSizeMake(75, 75)
        }else{
            return self.view.bounds.size
        }
    }
}
