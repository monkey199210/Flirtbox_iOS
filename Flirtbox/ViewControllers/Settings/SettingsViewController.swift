//
//  SettingsViewController.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 12.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit
import LGAlertView
import Bond

class SettingsViewController: UIViewController {

	@IBOutlet weak var controllerTopLabel: UILabel!
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		self.controllerTopLabel.text = "_SETTINGS".localized;
		self.localizeUI()
        self.bgImage.image = nil
        self.updateMainImage()
        FBEvent.onMainPictChanged().listen(self) { [unowned self] (_) -> Void in
            self.updateMainImage()
        }
        if AuthMe.isAuthenticated() {
            self.configure()
        }else{
            FBEvent.onAuthenticated().listen(self) { [unowned self] (isAuthenticated) -> Void in
                if isAuthenticated {
                    self.configure()
                }
            }
        }
    }
    private func updateMainImage() {
        UserProfile.getMainPict({ (image) -> Void in
            self.bgImage.image = image
        })
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsViewController.keyboardWillChangeFrame(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
    
    private var isPush = false
    private var isMail = false
    private func updateNotificationsField() {
        if(self.isPush && self.isMail){
            self.pushLabel.text = "Push/Mail notifications"
        }else if self.isPush {
            self.pushLabel.text = "_SETTINGS_PUSH_NOTIFICATIONS".localized
        }else if self.isMail {
            self.pushLabel.text = "Email notifications"
        }else{
            self.pushLabel.text = "_NONE".localized
        }
    }
    private func configure() {
        Net.settings().onSuccess { (settings) -> Void in
            for notification in settings.notifications {
                switch notification.name {
                case NotificationsName.NewMessage.rawValue:
                    self.newMessagesSwitch.on = notification.active
                case NotificationsName.MessageReply.rawValue:
                    self.messagesReplySwitch.on = notification.active
                case NotificationsName.MessageFromFaveUser.rawValue:
                    self.messagesFavesSwitch.on = notification.active
                case NotificationsName.PictureApproved.rawValue:
                    self.pictureApprovedSwitch.on = notification.active
                case NotificationsName.PictureDisapproved.rawValue:
                    self.pictureDeclinedSwitch.on = notification.active
                case NotificationsName.TechnicalIssue.rawValue:
                    self.technicalIssueSwitch.on = notification.active
                case NotificationsName.Newsletter.rawValue:
                    self.newsletterSwitch.on = notification.active
                default:break
                }
            }
            for settings in settings.settings {
                switch settings.name {
                case SettingsName.PrefShareprofile.rawValue:
                    self.allowToShareButton.selected = settings.active
                case SettingsName.PrefProfileSearchable.rawValue:
                    self.allowToSearchButton.selected = settings.active
                case SettingsName.PrefLocationUpdate.rawValue:
                    self.automaticallyUpdateButton.selected = settings.active
                case SettingsName.PrefPushNotifications.rawValue:
                    if settings.active {
						self.pushLabel.text = "_SETTINGS_PUSH_NOTIFICATIONS".localized;
                    }
                case SettingsName.PrefEmailNotifications.rawValue:
                    if settings.active {
						self.pushLabel.text = "_EMAIL".localized;
                    }
                default:break
                }
            }
        }
        if let user = UserProfile.currentUser() {
            configureWithUser(user)
        }
        FBEvent.onProfileReceived().listen(self, callback: { [unowned self] (user) -> Void in
            self.configureWithUser(user)
        })
        Net.notificationMedium().onSuccess { (notiffMiddles) -> Void in
            for value in notiffMiddles {
                if Int(value.id) == Net.SettingItems._EMAIL.rawValue && value.active {
                    self.isMail = true
                }else if Int(value.id) == Net.SettingItems._PUSH.rawValue && value.active {
                    self.isPush = true
                }
            }
            self.updateNotificationsField()
        }
    }
    private var user: FBUser?
    private func configureWithUser(user: FBUser) {
        self.user = user
        if let email = user.general.email.email {
            self.email.text = email
        }
        if let phone = user.general.phone.phone {
            self.phone.text = phone
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var blockView: UIView!
    @IBOutlet weak var pushLabel: UILabel!
    @IBOutlet weak var automaticallyUpdateButton: UIButton!
    @IBOutlet weak var allowToSearchButton: UIButton!
    @IBOutlet weak var allowToShareButton: UIButton!
    @IBOutlet weak var newMessagesSwitch: UISwitch!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var messagesReplySwitch: UISwitch!
    @IBOutlet weak var pictureDeclinedSwitch: UISwitch!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var messagesFavesSwitch: UISwitch!
    @IBOutlet weak var pictureApprovedSwitch: UISwitch!
    @IBOutlet weak var technicalIssueSwitch: UISwitch!
    @IBOutlet weak var newsletterSwitch: UISwitch!
	
	//MARK: - Localizable UI elements
	@IBOutlet weak var myAccountLabel: UILabel!
	@IBOutlet weak var emailAddrLabel: UILabel!
	@IBOutlet weak var emailValueLabel: UILabel!
	@IBOutlet weak var phoneNumberLabel: UILabel!
	@IBOutlet weak var phoneValueLabel: UILabel!
	@IBOutlet weak var nitificationMediumLabel: UILabel!
	@IBOutlet weak var notificationValueLabel: UILabel!
	@IBOutlet weak var changePasswordLabel: UILabel!
	@IBOutlet weak var deleteAccountLabel: UILabel!
	@IBOutlet weak var myProfileLabel: UILabel!
	@IBOutlet weak var whoMayContactMeLabel: UILabel!
	@IBOutlet weak var sharableLabel: UILabel!
	@IBOutlet weak var allowPeopleLabel: UILabel!
	@IBOutlet weak var privacyLabel: UILabel!
	@IBOutlet weak var profileSearchableLabel: UILabel!
	@IBOutlet weak var allowSearchIndexLabel: UILabel!
	@IBOutlet weak var autoUpdateLabel: UILabel!
	@IBOutlet weak var autoUpdateValueLabel: UILabel!
	@IBOutlet weak var notificationsTitleLabel: UILabel!
	@IBOutlet weak var newMessagesLabel: UILabel!
	@IBOutlet weak var messageReplyLabel: UILabel!
	@IBOutlet weak var messageFromFavsLabel: UILabel!
	@IBOutlet weak var pictureApprovedLabel: UILabel!
	@IBOutlet weak var pictureDeclinedLabel: UILabel!
	@IBOutlet weak var technicalIssuesLabel: UILabel!
	@IBOutlet weak var newsLetterLabel: UILabel!
	
	func localizeUI(){
		myAccountLabel.text = "_SETTINGS_MY_ACCOUNT".localized;
		emailAddrLabel.text = "_EMAIL".localized;
		phoneNumberLabel.text = "_PHONE_NUMBER".localized;
		nitificationMediumLabel.text = "_SETTINGS_NOTIFICATIONS_MEDIUM".localized;
		changePasswordLabel.text = "_CHANGE_PASSWORD".localized;
		deleteAccountLabel.text = "_DELETE_PROFILE".localized;
		myProfileLabel.text = "_SETTINGS_MY_ACCOUNT".localized;
		whoMayContactMeLabel.text = "_WHO_MAY_CONTACT_YOU".localized;
		sharableLabel.text = "_SETTINGS_SHARABLE".localized;
		allowPeopleLabel.text = "_SETTINGS_SHARABLE_SUMMARY".localized;
		privacyLabel.text = "_PRIVACY".localized;
		profileSearchableLabel.text = "_SETTINGS_PROFILE_SEARCHABLE".localized;
		allowSearchIndexLabel.text = "_SETTINGS_PROFILE_SEARCHABLE_SUMMARY".localized;
		notificationsTitleLabel.text = "_SETTINGS_NOTIFICATIONS".localized;
		newMessagesLabel.text = "_NEW_MESSAGE".localized;
		messageReplyLabel.text = "_SETTINGS_MESSAGE_REPLY".localized;
		messageFromFavsLabel.text = "_SETTINGS_MESSAGE_FAVORITE".localized;
		pictureApprovedLabel.text = "_PICTURE_APPROVED".localized;
		pictureDeclinedLabel.text = "_PICTURE_DISAPPROVED".localized;
		technicalIssuesLabel.text = "_TECHNICAL_ISSUES".localized;
		newsLetterLabel.text = "_NEWSLETTER".localized;
		autoUpdateLabel.text = "_SETTINGS_LOCATION_UPDATE".localized;
		autoUpdateValueLabel.text = "_LOCATION_RETRIEVE_AUTO".localized;
	}
	//-end oflocalizable ui elements
    
    // MARK: - Actions
    private var phoneSubmitAction: UIAlertAction?
    private var phoneTextField: UITextField?
    @IBAction func addPhoneAction(sender: AnyObject) {
        if let user = self.user {
            if user.general.phone.phone != nil && user.general.phone.phone!.length > 0  {
                //check, confirm
            }else{
                //add phone
                let alert = UIAlertController(title: "_PHONE_NUMBER".localized, message: "", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addTextFieldWithConfigurationHandler({(textField) -> Void in
                    textField.keyboardType = .PhonePad
                    self.phoneTextField = textField
                    textField.bnd_text.observe({ (text) -> Void in
                        self.phoneSubmitAction?.enabled = text?.length > 0
                    })
                })
                alert.addAction(UIAlertAction(title: "_CANCEL".localized.uppercaseString, style: UIAlertActionStyle.Cancel, handler:{(UIAlertAction)in
                    self.phoneTextField = nil
                    self.phoneSubmitAction = nil
                }))
                let phoneSubmitAction = UIAlertAction(title: "_SUBMIT".localized.uppercaseString, style: UIAlertActionStyle.Default, handler:{ (UIAlertAction)in
                    if let phone = self.phoneTextField where phone.text?.length > 0 {
                        Net.sendPhone(phone.text!).onFailure(callback: { (error) -> Void in
                            UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK").show()
                        })
                    }
                    self.phoneTextField = nil
                    self.phoneSubmitAction = nil
                })
                phoneSubmitAction.enabled = false
                self.phoneSubmitAction = phoneSubmitAction
                alert.addAction(phoneSubmitAction)
                self.presentViewController(alert, animated: true, completion: {
                })
            }
        }
    }
    private var emailTextField: UITextField?
    private var submitAction: UIAlertAction?
    func configurationTextField(textField: UITextField!){
        self.emailTextField = textField
        self.emailTextField?.keyboardType = .EmailAddress
        self.emailTextField?.bnd_text.observe({ (text) -> Void in
            if let submitAction = self.submitAction, let txt = text {
                submitAction.enabled = txt.isValidEmail()
            }
        })
		self.emailTextField?.placeholder = "_EMAIL".localized;
    }
    func handleCancel(alertView: UIAlertAction!){
        self.emailTextField = nil
        self.submitAction = nil
    }
    private var confirmCodeField: UITextField?
    private var isConfirmEmailAlertShowing = false
    private func showConfirdEmailAlert() {
        if !isConfirmEmailAlertShowing {
            isConfirmEmailAlertShowing = true
            let alert = UIAlertController(title: "_NOTIFY_CONFIRM_EMAIL".localized, message: "", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
                self.confirmCodeField = textField
            }
            alert.addAction(UIAlertAction(title: "_CANCEL".localized, style: UIAlertActionStyle.Cancel, handler: { (UIAlertAction)in
                self.isConfirmEmailAlertShowing = false
                self.confirmCodeField = nil
            }))
            alert.addAction(UIAlertAction(title: "_SUBMIT".localized, style: UIAlertActionStyle.Default, handler:{ (UIAlertAction)in
                if let confirmCodeField = self.confirmCodeField where confirmCodeField.text!.length > 0 {
                    Net.emailcode(confirmCodeField.text!).onFailure(callback: { (error) -> Void in
                        UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK").show()
                    }).onSuccess(callback: { (result) -> Void in
                        if let errorDescr = result.errorDescription {
                            UIAlertView(title: "Error", message: errorDescr, delegate: nil, cancelButtonTitle: "OK").show()
                        }
                    })
                }
                self.isConfirmEmailAlertShowing = false
                self.confirmCodeField = nil
            }))
            self.presentViewController(alert, animated: true, completion: {
            })
        }
    }
    @IBAction func addMailAction(sender: AnyObject) {
        if let user = self.user {
            if user.general.email.email != nil && user.general.email.email!.length > 0  {
                Net.emailStatus().onSuccess(callback: { (email) -> Void in
                    if !Net.checkBoolField(email.confirmed) {
                        self.showConfirdEmailAlert()
                    }
                })
            }else{
                let alert = UIAlertController(title: "_EMAIL".localized, message: "", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addTextFieldWithConfigurationHandler(configurationTextField)
                alert.addAction(UIAlertAction(title: "_CANCEL".localized, style: UIAlertActionStyle.Cancel, handler:handleCancel))
                let submitAction = UIAlertAction(title: "_SUBMIT".localized, style: UIAlertActionStyle.Default, handler:{ (UIAlertAction)in
                    if let email = self.emailTextField {
                        Net.sendemail(email.text!).onFailure(callback: { (error) -> Void in
                            UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK").show()
                        })
                    }
                    self.emailTextField = nil
                    self.submitAction = nil
                })
                submitAction.enabled = false
                self.submitAction = submitAction
                alert.addAction(submitAction)
                self.presentViewController(alert, animated: true, completion: {
                })
            }
        }
    }
    @IBAction func newsletterSwitchAction(sender: AnyObject) {
        Net.updateNotifications(Net.UserNotifications._NEWSLETTER.rawValue, value: self.newsletterSwitch.on)
    }
    @IBAction func technicalIssueSwitchAction(sender: AnyObject) {
        Net.updateNotifications(Net.UserNotifications._TECHNICAL_ISSUES.rawValue, value: self.technicalIssueSwitch.on)
    }
    @IBAction func pictureDeclinedSwitchAction(sender: AnyObject) {
        Net.updateNotifications(Net.UserNotifications._PICTURE_DISAPPROVED.rawValue, value: self.pictureDeclinedSwitch.on)
    }
    @IBAction func pictureApprovedSwitchAction(sender: AnyObject) {
        Net.updateNotifications(Net.UserNotifications._PICTURE_APPROVED.rawValue, value: self.pictureApprovedSwitch.on)
    }
    @IBAction func messagesFromFaveAction(sender: AnyObject) {
        Net.updateNotifications(Net.UserNotifications._MESSAGE_FROM_FAVOURITE_USER.rawValue, value: self.messagesFavesSwitch.on)
    }
    @IBAction func messagesReplySwitchAction(sender: AnyObject) {
        Net.updateNotifications(Net.UserNotifications._MESSAGE_REPLY.rawValue, value: self.messagesReplySwitch.on)
    }
    @IBAction func newMessagesSwitchAction(sender: AnyObject) {
        Net.updateNotifications(Net.UserNotifications._NEW_MESSAGE.rawValue, value: self.newMessagesSwitch.on)
    }
    @IBAction func autoApdateAction(sender: AnyObject) {
        self.automaticallyUpdateButton.selected = !self.automaticallyUpdateButton.selected
        Net.updateSettings(Net.UserSettings.pref_location_update.rawValue, value: self.automaticallyUpdateButton.selected)
    }
    @IBAction func allowSearchEnginesAction(sender: AnyObject) {
        self.allowToSearchButton.selected = !self.allowToSearchButton.selected
        Net.updateSettings(Net.UserSettings.pref_profile_searchable.rawValue, value: self.allowToSearchButton.selected)
    }
    @IBAction func allowShareAction(sender: AnyObject) {
        self.allowToShareButton.selected = !self.allowToShareButton.selected
        Net.updateSettings(Net.UserSettings.pref_shareprofile.rawValue, value: self.allowToShareButton.selected)
    }
    @IBAction func deleteAccAction(sender: AnyObject) {
        if let deleteAccViewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("DeleteAccViewController") as? DeleteAccViewController {
            deleteAccViewController.willMoveToParentViewController(self)
            deleteAccViewController.settingsViewController = self
            self.addChildViewController(deleteAccViewController)
            deleteAccViewController.view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(deleteAccViewController.view)
            deleteAccViewController.didMoveToParentViewController(self)
            
            Restraint(deleteAccViewController.view, .CenterX, .Equal, self.view, .CenterX).addToView(self.view)
            yCenterConstraint = Restraint(deleteAccViewController.view, .CenterY, .Equal, self.view, .CenterY).addToView(self.view)
            Restraint(deleteAccViewController.view, .Width,  .Equal, 300).addToView(deleteAccViewController.view)
            Restraint(deleteAccViewController.view, .Height,  .Equal, 200).addToView(deleteAccViewController.view)
            
            UIView.appearWithScale(deleteAccViewController.view, duration: FBoxConstants.kAnimationFastDuration, completition: {
                deleteAccViewController.passwordField.becomeFirstResponder()
            })
            FBoxHelper.getMainController()?.hideMenuButton(false)
            UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
                self.blockView.alpha = 1.0
                }, completion:nil)
        }
    }
    private var yCenterConstraint: NSLayoutConstraint?
    @IBAction func changePassAction(sender: AnyObject) {
        if let changePassViewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("ChangePassViewController") as? ChangePassViewController {
            changePassViewController.willMoveToParentViewController(self)
            changePassViewController.settingsViewController = self
            self.addChildViewController(changePassViewController)
            changePassViewController.view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(changePassViewController.view)
            changePassViewController.didMoveToParentViewController(self)
            
            Restraint(changePassViewController.view, .CenterX, .Equal, self.view, .CenterX).addToView(self.view)
            yCenterConstraint = Restraint(changePassViewController.view, .CenterY, .Equal, self.view, .CenterY).addToView(self.view)
            Restraint(changePassViewController.view, .Width,  .Equal, 300).addToView(changePassViewController.view)
            Restraint(changePassViewController.view, .Height,  .Equal, 200).addToView(changePassViewController.view)
            
            UIView.appearWithScale(changePassViewController.view, duration: FBoxConstants.kAnimationFastDuration, completition: {
                changePassViewController.newPassword.becomeFirstResponder()
            })
            FBoxHelper.getMainController()?.hideMenuButton(false)
            UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
                self.blockView.alpha = 1.0
                }, completion:nil)
        }
    }
    @IBAction func notificationsAction(sender: AnyObject) {
        if let notificationsMiddleViewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("NotificationsMiddleViewController") as? NotificationsMiddleViewController {
            notificationsMiddleViewController.willMoveToParentViewController(self)
            notificationsMiddleViewController.settingsViewController = self
            notificationsMiddleViewController.isMail = self.isMail
            notificationsMiddleViewController.isPush = self.isPush
            self.addChildViewController(notificationsMiddleViewController)
            notificationsMiddleViewController.view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(notificationsMiddleViewController.view)
            notificationsMiddleViewController.didMoveToParentViewController(self)
            
            Restraint(notificationsMiddleViewController.view, .CenterX, .Equal, self.view, .CenterX).addToView(self.view)
            Restraint(notificationsMiddleViewController.view, .CenterY, .Equal, self.view, .CenterY).addToView(self.view)
            Restraint(notificationsMiddleViewController.view, .Width,  .Equal, 300).addToView(notificationsMiddleViewController.view)
            Restraint(notificationsMiddleViewController.view, .Height,  .Equal, 200).addToView(notificationsMiddleViewController.view)
            
            UIView.appearWithScale(notificationsMiddleViewController.view, duration: FBoxConstants.kAnimationFastDuration, completition: {
                
            })
            FBoxHelper.getMainController()?.hideMenuButton(false)
            UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
                self.blockView.alpha = 1.0
                }, completion:nil)
        }
    }
    
    // MARK: - Helper methods
    func submitNotificationMedium(selections: (push: Bool, email: Bool)) {
        self.isPush = selections.push
        self.isMail = selections.email
        self.updateNotificationsField()
        Net.notificationMedium(String(Net.SettingItems._PUSH.rawValue), value: selections.push)
        Net.notificationMedium(String(Net.SettingItems._EMAIL.rawValue), value: selections.email)
    }
    func closeNotiffMedium() {
        FBoxHelper.getMainController()?.showMenuButton(false)
        UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.blockView.alpha = 0.0
            }, completion:nil)
    }
}
