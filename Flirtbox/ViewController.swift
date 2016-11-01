//
//  ViewController.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 05.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit
import AFDateHelper
import MobileCoreServices
import Bond
import LGAlertView
import Async
import FBSDKLoginKit
import Nuke

enum eSignUpDisclaimerNavigationParam {
	case TermsAndConditions
	case PrivacyPolicy
}
class ViewController: UIViewController, UITextFieldDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, FindLocationDelegate, WebContentControlDelegate {

	// MARK: fields
	private var loginAttemptsCount = 0;
	private var username: String = "" {
		didSet{
			if username.length > 0 {
				self.signNameEnabledLabel.hidden = false
				self.usernameLimitLabel.text = "\(username.length)/\(kUsernameCharactersLimit)";
				if username.isValidUserName() {
					Net.checkUsernameField(username).onSuccess(callback: { (enabled) -> Void in
						self.signUsernameEnabled = enabled && self.username.isValidUserName()
					})
				}else{
					self.signUsernameEnabled = false
				}

			}else{
				self.signNameEnabledLabel.hidden = true
				self.signNameEnabledLabel.text = ""
			}
			checkSignUpEnabling()
		}
	}
	private var email: String = "" {
		didSet{
			if (email.length > 0){
				self.signEmailEnabledLabel.hidden = false
				if email.isValidEmail() {
					Net.checkEmailField(email).onSuccess(callback: { (enabled) -> Void in
						self.signEmailEnabled = enabled && self.email.isValidEmail()
					})
				}else{
					self.signEmailEnabled = false
				}
			}
			else{
				self.signEmailEnabledLabel.hidden = true
				self.signEmailEnabledLabel.text = ""
			}
			checkSignUpEnabling()
		}
	}
	private var birthdate : NSDate? = nil{
		didSet{
			if let date = birthdate {
				self.signBirthdayButton.setTitle(date.toString(format: .Custom("dd MMMM yyyy")).uppercaseString, forState: .Normal)
			}
			checkSignUpEnabling()
		}
	}
	private var coordinates : (latitude: Double, longitude: Double)? = nil{
		didSet{
			print("current location lat:long - \(coordinates?.latitude):\(coordinates?.longitude)")
			checkSignUpEnabling()
		}
	}
    // MARK: - Lifecycle
	private var signGender : Bool? = nil{
        didSet {
            self.manButton.selected = signGender!
            self.girlButton.selected = !signGender!
            if signGender! {
                self.signSexuality = Sexuality.Msf
            }else{
                self.signSexuality = Sexuality.Fsm
            }
        }
    }
    private var signSexuality: Sexuality = Sexuality.Msf
    private var isAutomaticallyLocation = false
    private var selectedPlace: FBPlace? {
        didSet {
            guard let selectedPlace = self.selectedPlace else {return}
            self.signLocationButton.setTitle(selectedPlace.geoname, forState: .Normal)
            checkSignUpEnabling()
        }
    }

    private var facebookAccessToken: String?
    override func viewDidLoad() {
        super.viewDidLoad()
		self.privacyPolicyButton.setTitle("_PRIVACY_POLICY".localized, forState: .Normal);
		self.termsAndConditions.setTitle("_TERMS_AND_CONDITIONS".localized , forState: .Normal);
		self.troubleshooButton.setTitle("_TROUBLESHOOT".localized, forState: .Normal);
		if let label = self.termsAndConditions.titleLabel{
			label.numberOfLines = 2;
			label.textAlignment = .Center;
		}
        self.facebookAlert.alpha = 0.0
        self.facebookBlockView.alpha = 0.0
        self.facebookDone.enabled = false
        self.selectedLine.alpha = 0.0
        self.equalHeight.constant = -UIApplication.sharedApplication().statusBarFrame.height
        checkLoginNowEnabling()
        checkSignUpEnabling()
        if let image = UserProfile.circledNeedToLoadImage() {
            self.profileCircleImage.image = image
            self.signInImage.image = image
        }
        self.signNameEnabledLabel.hidden = true
        self.signNameEnabledLabel.text = ""
        self.signEmailEnabledLabel.hidden = true
        self.signEmailEnabledLabel.text = ""
        LocationManager.sharedInstance.setLocationProcessBlock { (lat, lon) -> () in
			self.coordinates = (lat, lon);
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillChangeFrame(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillChangeFrame(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            scrollBottom.constant = keyboardSize.height
            signScrollBottom.constant = keyboardSize.height
            UIView.animateWithDuration(FBoxConstants.kAnimationDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
                self.view.layoutIfNeeded()
                }, completion:{(_) -> Void in
            })
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        scrollBottom.constant = 0.0
        signScrollBottom.constant = 0.0
        UIView.animateWithDuration(FBoxConstants.kAnimationDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion:{(_) -> Void in
                
        })
    }
    // MARK: - Outlets
	@IBOutlet weak var usernameLimitLabel: UILabel!
    @IBOutlet weak var facebookAlert: UIView!
    @IBOutlet weak var signLocationButton: UIButton!
    @IBOutlet weak var signBirthdayButton: UIButton!
    @IBOutlet weak var signEmailEnabledLabel: UILabel!
    @IBOutlet weak var signNameEnabledLabel: UILabel!
    @IBOutlet weak var girlButton: UIButton!
    @IBOutlet weak var manButton: UIButton!
    @IBOutlet weak var signInImage: UIImageView!
    @IBOutlet weak var signInImageButton: UIButton!
    @IBOutlet weak var profileCircleImage: UIImageView!
    @IBOutlet weak var equalHeight: NSLayoutConstraint!
    @IBOutlet weak var loginNowButton: UIButton!
    @IBOutlet weak var loginPass: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpScrollview: UIScrollView!
    @IBOutlet weak var loginMail: UITextField!
    @IBOutlet weak var signUserName: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signScrollBottom: NSLayoutConstraint!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var signMail: UITextField!
    @IBOutlet weak var loginScrollView: UIScrollView!
    @IBOutlet weak var scrollBottom: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    @IBOutlet weak var selectedLine: UIImageView!
    @IBOutlet weak var selectedLeading: NSLayoutConstraint!
    @IBOutlet weak var facebookBlockView: UIView!
    @IBOutlet weak var facebookImage: UIImageView!
    @IBOutlet weak var facebookUsernameEnabled: UILabel!
    @IBOutlet weak var facebookUserName: UITextField!
    @IBOutlet weak var facebookDone: UIButton!
	@IBOutlet weak var privacyPolicyButton: UIButton!
	@IBOutlet weak var termsAndConditions: UIButton!
	@IBOutlet weak var troubleshooButton: UIButton!
    // MARK: - Actions
	@IBAction func troubleshootClicked(sender: AnyObject) {
		let troubleshootAlert = LGAlertView(textFieldsStyleWithTitle: "_TROUBLESHOOT".localized,
			message: "_SIGN_UP_TROUBLESHOOT".localized,
			numberOfTextFields: 2,
			textFieldsSetupHandler: {(textField, number) in
				textField.placeholder = number == 0 ? "_EMAIL".localized : "_MESSAGE".localized;
				textField.autocapitalizationType = number == 0 ? .None : .Sentences;
			}, buttonTitles: [],
			cancelButtonTitle: "_CANCEL".localized,
			destructiveButtonTitle: "_SEND".localized);
		troubleshootAlert.destructiveHandler = { alert in
			print("send");
			Net.sendTroubleshoot(alert.textFieldsArray[0].text, message: alert.textFieldsArray[1].text).onSuccess(callback: {_ in 
				print("successfully sent!");
				GoogleAnalitics.send(FBNet.TROUBLESHOOT_ANALYTICS_CATEGORY, action: FBNet.TROUBLESHOOT_ANALYTICS_SENT);
				let alertController = UIAlertController(title: "_FBMAILSENT".localized, message: "", preferredStyle: .Alert);
				let cancelAction = UIAlertAction(title: "Ok", style: .Cancel) { (action) in
					
				}
				alertController.addAction(cancelAction)
				self.presentViewController(alertController, animated: true) {
				}
			}).onFailure(callback: {_ in
				

			});
		};
		troubleshootAlert.showAnimated(true, completionHandler: {});
	}
    @IBAction func facebookDoneAction(sender: AnyObject) {
        if let accessToken = self.facebookAccessToken {
            AuthMe.facebookSignUp(accessToken, username: self.facebookUserName.text!).onSuccess(callback: { (_) -> Void in
                self.closeFacebookView()
                LocationManager.sharedInstance.stopUpdating()
                FBoxHelper.getMainController()?.closeSignUp()
                self.profileCircleImage.image = UIImage(named: R.AssetsAssets.profileAddAlertImg.takeUnretainedValue() as String)
                self.signInImage.image = nil
                self.facebookImage.image = nil
                GoogleAnalitics.send(GoogleAnalitics.Signup.Category, action: GoogleAnalitics.Signup.SIGNUP_FB_SUCCESS)
            }).onFailure(callback: { (error) -> Void in
                UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK").show()
                GoogleAnalitics.send(GoogleAnalitics.Signup.Category, action: GoogleAnalitics.Signup.SIGNUP_FB_ERROR)
            })
        }
    }
    @IBAction func changeFacebookImageAction(sender: AnyObject) {
        self.openImageGetter()
    }
    @IBAction func closeFacebookAlertAction(sender: AnyObject) {
        self.profileCircleImage.image = UIImage(named: R.AssetsAssets.profileAddAlertImg.takeUnretainedValue() as String)
        self.signInImage.image = nil
        self.facebookImage.image = nil
        UserProfile.removeNeedToLoadImage()
        self.closeFacebookView()
    }
	@IBAction func getBirthdayAction(sender: AnyObject) {
        self.view.endEditing(true)
        let picker = UIDatePicker()
        picker.datePickerMode = .Date
        let maxYear = NSDate().year() - 17
        let month = NSDate().month() > 9 ? "0\(NSDate().month())" : "\(NSDate().month())"
        let day = NSDate().day() > 9 ? "0\(NSDate().day())" : "\(NSDate().day())"
        let maxDate = NSDate(fromString:  "\(maxYear)-\(month)-\(day)", format: .ISO8601(nil))
        picker.maximumDate = maxDate
        let datePicker = LGAlertView(viewStyleWithTitle: "_DATE_OF_BIRTH".localized, message: "", view: picker, buttonTitles: ["OK"], cancelButtonTitle: nil, destructiveButtonTitle: nil, actionHandler: { [weak picker, weak self] (alertView, name, index) -> Void in
            if let selectedDate = picker?.date {
                self?.birthdate = selectedDate
            }
        }, cancelHandler: nil, destructiveHandler: nil)
        datePicker.showAnimated(true, completionHandler: nil)
    }
    @IBAction func girlAction(sender: AnyObject) {
        self.signGender = false
    }
    @IBAction func manAction(sender: AnyObject) {
        self.signGender = true
    }
    @IBAction func getImageAction(sender: AnyObject) {
        self.openImageGetter()
    }
    @IBAction func getLocation(sender: AnyObject) {
        let alert = UIAlertView(title: "_LOCATION_RETRIEVAL".localized, message: "", delegate: self, cancelButtonTitle: "_CANCEL".localized, otherButtonTitles: "_YES".localized)
        alert.tag = kLocationTag
        alert.show()
    }
    private let kMailTag = 1
    private let kLocationTag = 2
    @IBAction func forgotAction(sender: AnyObject) {
        let alert = UIAlertView(title: "Forgot", message: "Enter mail", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Done")
        alert.tag = kMailTag
        alert.alertViewStyle = .PlainTextInput
        if let emailTextField = alert.textFieldAtIndex(0) {
            emailTextField.keyboardType = .EmailAddress
        }
        alert.show()
    }
    @IBAction func createAccount(sender: AnyObject) {
        AuthMe.signUp(self.username, sexuality: self.signSexuality, email: self.email, birthdate: self.birthdate!, place: selectedPlace, coordinates: coordinates!).onSuccess { (_) -> Void in
            LocationManager.sharedInstance.stopUpdating()
            FBoxHelper.getMainController()?.closeSignUp()
            self.profileCircleImage.image = UIImage(named: R.AssetsAssets.profileAddAlertImg.takeUnretainedValue() as String)
            self.signInImage.image = nil
            self.facebookImage.image = nil
            GoogleAnalitics.send(GoogleAnalitics.Signup.Category, action: GoogleAnalitics.Signup.SIGNUP_SUCCESS)
        }.onFailure { (error) -> Void in
            UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK").show()
            GoogleAnalitics.send(GoogleAnalitics.Signup.Category, action: GoogleAnalitics.Signup.SIGNUP_ERROR)
        }
    }
    @IBAction func facebookLoginAction(sender: AnyObject) {
        let login = FBSDKLoginManager()
        login.logInWithReadPermissions(["user_about_me"], fromViewController: self) { (result, error) -> Void in
            if let accessToken = FBSDKAccessToken.currentAccessToken() where result != nil && error == nil {
                AuthMe.facebookLogin(accessToken.tokenString).onSuccess(callback: { (_) -> Void in
                    self.closeFacebookView()
                    LocationManager.sharedInstance.stopUpdating()
                    FBoxHelper.getMainController()?.closeSignUp()
                    self.profileCircleImage.image = UIImage(named: R.AssetsAssets.profileAddAlertImg.takeUnretainedValue() as String)
                    self.signInImage.image = nil
                    self.facebookImage.image = nil
                    GoogleAnalitics.send(GoogleAnalitics.AuthenticatorSplashScreen.Category, action: GoogleAnalitics.AuthenticatorSplashScreen.LOGIN_FB_SUCCESS)
                }).onFailure(callback: { (error) -> Void in
                    UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK").show()
                    GoogleAnalitics.send(GoogleAnalitics.AuthenticatorSplashScreen.Category, action: GoogleAnalitics.AuthenticatorSplashScreen.LOGIN_FB_ERROR)
                })
            }else if error != nil {
                print(error)
                GoogleAnalitics.send(GoogleAnalitics.AuthenticatorSplashScreen.Category, action: GoogleAnalitics.AuthenticatorSplashScreen.FB_SDK_ERROR)
            }
        }
    }
    @IBAction func facebookAction(sender: AnyObject) {
        let login = FBSDKLoginManager()
        login.logInWithReadPermissions(["user_about_me"], fromViewController: self) { [unowned self] (result, error) -> Void in
            if result != nil && error == nil {
                Webservice.showBlocking(true)
                let requestMe = FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields": "first_name"])
                let connection = FBSDKGraphRequestConnection()
                connection.addRequest(requestMe, completionHandler: { (connection, result, error) -> Void in
                    if let accessToken = FBSDKAccessToken.currentAccessToken() where result != nil && error == nil {
                        self.facebookAccessToken = accessToken.tokenString
                        if let name = result["first_name"] as? String {
                            if name.isValidUserName() {
                                Net.checkUsernameField(name).onSuccess(callback: { (enabled) -> Void in
                                    if enabled {
                                        self.facebookUserName.text = name
                                    }
                                    self.isFacebookUsernameFreeAndValid = enabled && name.isValidUserName()
                                })
                            }else{
                                self.isFacebookUsernameFreeAndValid = false
                            }
                        }
                        let height = Int(FBoxHelper.getScreenSize().height)
                        let width = Int(FBoxHelper.getScreenSize().width)
                        let request = FBSDKGraphRequest(graphPath: "/me/picture", parameters: ["height":"\(height)", "redirect":"0", "width":"\(width)"])
                        request.startWithCompletionHandler({ (connection, result, error) -> Void in
                            if result != nil && error == nil {
                                if let data = result["data"] as? NSDictionary {
                                    if let url = data["url"] as? String {
                                        var request = ImageRequest(URLRequest: NSURLRequest(URL: NSURL(string: url)!))
                                        request.targetSize = CGSize(width: CGFloat(width), height: CGFloat(height))
                                        Nuke.taskWith(request) { response in
                                            switch response {
                                            case let .Success(image, _):
                                                var circledImage: UIImage?
                                                self.facebookImage.image = nil
                                                Async.background {
                                                    UserProfile.setNeedToLoadImage(image)
                                                    circledImage = UserProfile.circledNeedToLoadImage()
                                                    }.main {
                                                        self.profileCircleImage.image = circledImage
                                                        self.signInImage.image = circledImage
                                                        self.facebookImage.image = circledImage
                                                        self.checkSignUpEnabling()
                                                        self.checkFacebookSignupEnabling()
                                                        self.checkFacebookNameField()
                                                        self.openFacebookView()
                                                        Webservice.closeBlocking(true)
                                                }
                                            case let .Failure(error):
                                                print(error)
                                                self.openFacebookView()
                                                Webservice.closeBlocking(true)
                                            }
                                            }.resume()
                                    }else{
                                        self.openFacebookView()
                                        Webservice.closeBlocking(true)
                                    }
                                }else{
                                    self.openFacebookView()
                                    Webservice.closeBlocking(true)
                                }
                            }else if error != nil {
                                print(error)
                                self.openFacebookView()
                                Webservice.closeBlocking(true)
                            }
                        })
                    }else if error != nil {
                        print(error)
                        Webservice.closeBlocking(true)
                    }
                })
                connection.start()
            }else if error != nil {
                print(error)
            }
        }
    }
    @IBAction func loginNow(sender: AnyObject) {
        login()
    }
    @IBAction func textFieldChanged(sender: UITextField) {
		switch sender {
		case self.signUserName:
			self.username = sender.text ?? "";
		case self.signMail:
			self.email = sender.text ?? "";
			
		default:
			break;
		}
		
        checkLoginNowEnabling()
    }
    @IBAction func reasonAction(sender: AnyObject) {
        var reason = "";
        if username.length == 0 || !signUsernameEnabled {
            reason = "_SIGN_UP_USERNAME_MISSING".localized
        }else if email.length == 0 || !signEmailEnabled {
            reason = "_SIGN_UP_EMAIL_MISSING".localized
        }else if birthdate == nil {
            reason = "_DOB_MISSING".localized
		}else if (coordinates == nil){
			reason = "_LOCATION_RETRIEVAL_ERROR".localized;
		}
			/*else if selectedPlace == nil {
            reason = "_SIGN_UP_LOCATION_MISSING".localized
        }*/else if self.signInImage.image == nil {
            reason = "_SIGN_UP_PICTURE_MISSING".localized
        }
        if reason.length > 0 {
            Drop.down(reason, state: .Default)
        }
    }
    @IBAction func facebookNameChanged(sender: UITextField) {
        self.facebookUsernameEnabled.text = ""
        if let userName = self.facebookUserName.text {
            if userName.isValidUserName() {
                Net.checkUsernameField(userName).onSuccess(callback: { (enabled) -> Void in
                    self.isFacebookUsernameFreeAndValid = enabled && userName.isValidUserName()
                })
            }else{
                self.isFacebookUsernameFreeAndValid = false
            }
        }
    }
	@IBAction func policy_TouchUpInside(sender: AnyObject) {
		self.openPage(.PrivacyPolicy);
	}
    @IBAction func termsAction(sender: AnyObject) {
		self.openPage(.TermsAndConditions);
    }
    @IBAction func facebookReasonAction(sender: AnyObject) {
        var reason = ""
        if facebookUserName.text?.length == 0 || !self.isFacebookUsernameFreeAndValid {
            reason = "_SIGN_UP_USERNAME_MISSING".localized
        }else if self.facebookImage.image == nil {
            reason = "_PICTURE_SELECT".localized
        }
        if reason.length > 0 {
            Drop.down(reason, state: .Default)
        }
    }
    private let kEnabledText = "✔︎"
    private let kEnabledColor = UIColor(red:0.33, green:0.69, blue:0.16, alpha:1)
    private let kDisabledText = "✘"
    private let kDisabledColor = UIColor(red:0.84, green:0.23, blue:0.15, alpha:1)
	private let kUsernameCharactersLimit = 16;
	@IBAction func closeKeyboard(sender: AnyObject) {
        self.view.endEditing(true)
    }
    @IBAction func signUpAction(sender: AnyObject) {
        openSignUp()
    }
    @IBAction func signInAction(sender: AnyObject) {
        openLogin()
    }
    
    // MARK: - Helper methods
	func handleForgottenPassword () {
		let alert = UIAlertView(title: "_LOST_YOUR_PASSWORD".localized, message: "_SIGN_UP_EMAIL_MISSING".localized, delegate: self, cancelButtonTitle: "_CANCEL".localized, otherButtonTitles: "_SUBMIT".localized);
		alert.tag = kMailTag;
		alert.alertViewStyle = .PlainTextInput;
		if let emailTextField = alert.textFieldAtIndex(0) {
			emailTextField.keyboardType = .EmailAddress;
		}
		alert.show();
	}
    private func checkFacebookNameField() {
        if self.facebookAlert.alpha == 1.0 && self.facebookUserName.text?.length == 0 {
            self.facebookUserName.becomeFirstResponder()
        }
    }
    private func openImageGetter() {
        self.view.endEditing(true)
        let actionsheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "_CANCEL".localized, destructiveButtonTitle: nil, otherButtonTitles: "Choose Photo", "Take Photo")
        actionsheet.showInView(self.view)
    }
    private func openFacebookView() {
        UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.facebookAlert.alpha = 1.0
            self.facebookBlockView.alpha = 1.0
            }, completion:{ _ in
                if self.facebookUserName.text?.length == 0 {
                    self.facebookUserName.becomeFirstResponder()
                }
        })
    }
    private func closeFacebookView() {
        self.view.endEditing(true)
        UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.facebookAlert.alpha = 0.0
            self.facebookBlockView.alpha = 0.0
            }, completion:nil)
    }
    private var signUsernameEnabled = false {
        didSet {
            if signUsernameEnabled {
                self.signNameEnabledLabel.text = kEnabledText
                self.signNameEnabledLabel.textColor = kEnabledColor
            }else{
                self.signNameEnabledLabel.text = kDisabledText
                self.signNameEnabledLabel.textColor = kDisabledColor
            }
//            checkSignUpEnabling()
        }
    }
    private var isFacebookUsernameFreeAndValid = false {
        didSet {
            if self.facebookUserName.text?.length > 0 {
                if isFacebookUsernameFreeAndValid {
                    self.facebookUsernameEnabled.text = kEnabledText
                    self.facebookUsernameEnabled.textColor = kEnabledColor
                }else{
                    self.facebookUsernameEnabled.text = kDisabledText
                    self.facebookUsernameEnabled.textColor = kDisabledColor
                }
            }else{
                self.facebookUsernameEnabled.text = ""
            }
            checkFacebookSignupEnabling()
        }
    }
    private var signEmailEnabled = false {
        didSet {
            if signEmailEnabled {
                self.signEmailEnabledLabel.text = kEnabledText
                self.signEmailEnabledLabel.textColor = kEnabledColor
            }else{
                self.signEmailEnabledLabel.text = kDisabledText
                self.signEmailEnabledLabel.textColor = kDisabledColor
            }
            checkSignUpEnabling()
        }
    }
    private func checkFacebookSignupEnabling() -> Bool {
        if facebookUserName.text?.length > 0 && self.isFacebookUsernameFreeAndValid && self.facebookImage.image != nil {
            facebookDone.enabled = true
        }else{
            facebookDone.enabled = false
        }
        return facebookDone.enabled
    }
    private func checkSignUpEnabling() -> Bool {
        if username.length > 0 &&
			email.length > 0 &&
			signUsernameEnabled &&
			signEmailEnabled &&
			birthdate != nil &&
			//(isAutomaticallyLocation || selectedPlace != nil) &&
			coordinates != nil &&
			self.signInImage.image != nil {
            createAccountButton.enabled = true
        }else{
            createAccountButton.enabled = false
        }
        return createAccountButton.enabled
    }
    private func login() {
        self.view.endEditing(true)
		if(self.loginAttemptsCount >= 3){
			self.handleForgottenPassword();
		}
		else{
			AuthMe.auth(self.loginMail.text!, password: self.loginPass.text!).onSuccess { (_) -> Void in
					FBoxHelper.getMainController()?.closeSignUp()
					self.profileCircleImage.image = UIImage(named: R.AssetsAssets.profileAddAlertImg.takeUnretainedValue() as String)
					self.signInImage.image = nil
					self.facebookImage.image = nil
					GoogleAnalitics.send(GoogleAnalitics.Login.Category, action: GoogleAnalitics.Login.LOGIN)
				}.onFailure { (error) -> Void in
//					self.loginMail.text = ""
//					self.loginPass.text = ""
					UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK").show()
					GoogleAnalitics.send(GoogleAnalitics.Login.Category, action: GoogleAnalitics.Login.LOGIN_ERROR)
					self.loginAttemptsCount += 1; //swift 3 and stuff
			}
		}
    }
    private func checkLoginNowEnabling() -> Bool {
        if loginMail.text?.length > 0 && loginPass.text?.length > 0 {
            loginNowButton.enabled = true
        }else{
            loginNowButton.enabled = false
        }
        return loginNowButton.enabled
    }
    private func openLogin() {
//        LocationManager.sharedInstance.stopUpdating()
        self.loginButton.selected = true
        self.signUpButton.selected = false
        self.loginScrollView.alpha = 1.0
        self.signUpScrollview.alpha = 0.0
        self.view.endEditing(true)
        selectedLeading.constant = self.view.bounds.size.width / 2.0
        openBottom()
    }
    private func openSignUp() {
//        LocationManager.sharedInstance.startUpdating()
        self.loginButton.selected = false
        self.signUpButton.selected = true
        self.loginScrollView.alpha = 0.0
        self.signUpScrollview.alpha = 1.0
        self.view.endEditing(true)
        selectedLeading.constant = 0.0
		self.signUpScrollview.contentSize = CGSize(width: UIScreen.mainScreen().bounds.width, height: self.troubleshooButton.frame.maxY + 15);
        openBottom()
    }
    private func openBottom() {
        bottomConstraint.constant = self.view.frame.size.height - buttonHeight.constant - UIApplication.sharedApplication().statusBarFrame.height
        UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.selectedLine.alpha = 1.0
            }, completion:nil)
    }
    private func closeBottom() {
        self.loginButton.selected = false
        self.signUpButton.selected = false
        bottomConstraint.constant = 0.0
        UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.selectedLine.alpha = 0.0
            }, completion:nil)
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
		switch textField {
		case self.signUserName:
			self.signMail.becomeFirstResponder();
		case self.loginMail:
			self.loginPass.becomeFirstResponder();
		case self.loginPass:
//			if checkLoginNowEnabling() {
			self.loginPass.resignFirstResponder()
			login();
		default:
			textField.resignFirstResponder();
		}
        return true
    }
	func textFieldDidBeginEditing(textField: UITextField) {
		if(textField == signUserName || textField == loginMail){
			username = textField.text!;
		}
		else if(textField == signMail){
			email = textField.text!;
		}
	}
	func textFieldDidEndEditing(textField: UITextField) {
		print(textField.text);
		if(textField == signUserName || textField == loginMail){
			username = textField.text!;
		}
		else if(textField == signMail){
			email = textField.text!;
		}
	}
    // MARK: - UIAlertViewDelegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.tag == kMailTag {
            if let email = alertView.textFieldAtIndex(0)?.text where email.length > 0 && buttonIndex == 1 {
                Net.resetPassword(email).onSuccess(callback: { (_) -> Void in
                    UIAlertView(title: "Mail sent", message: "", delegate: nil, cancelButtonTitle: "OK").show()
                }).onFailure(callback: { (error) -> Void in
                    UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK").show()
                })
            }
        }else if alertView.tag == kLocationTag {
            if alertView.cancelButtonIndex == buttonIndex {
                isAutomaticallyLocation = false
                if let nav = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("FindLocationTableViewControllerNav") as? UINavigationController {
                    if let findLocationTableViewController = nav.viewControllers.first as? FindLocationTableViewController {
                        findLocationTableViewController.delegate = self
                    }
                    self.presentViewController(nav, animated: true, completion: nil)
                }
            }else{
                isAutomaticallyLocation = true
                self.selectedPlace = nil
                checkSignUpEnabling()
            }
        }
        self.view.endEditing(true)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            var circledImage: UIImage?
            self.profileCircleImage.image = UIImage(named: R.AssetsAssets.profileAddAlertImg.takeUnretainedValue() as String)
            self.signInImage.image = nil
            Async.background {
                let fixedImage = fixImageOrientation(image)
                UserProfile.setNeedToLoadImage(fixedImage)
                circledImage = UserProfile.circledNeedToLoadImage()
                }.main {
                    self.profileCircleImage.image = circledImage
                    self.signInImage.image = circledImage
                    self.facebookImage.image = circledImage
                    self.checkSignUpEnabling()
                    self.checkFacebookSignupEnabling()
                    self.checkFacebookNameField()
            }
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
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
        }else{
            self.checkFacebookNameField()
        }
    }
    
    // MARK: - UIPickerViewDataSource
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
	
    
    // MARK: - FindLocationDelegate
    func selectedPlace(place: FBPlace) {
        self.selectedPlace = place
    }
	//MARK: - terms&conditions vs privacy policy
	var fadingView : UIView!
	var dialogContentView: WebContentControl!
	func openPage(navigationParam : eSignUpDisclaimerNavigationParam){
		self.fadingView = UIView(frame: UIScreen.mainScreen().bounds);
		fadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5);
		self.dialogContentView = NSBundle.mainBundle().loadNibNamed("WebContentControl", owner: self, options: nil).first as! WebContentControl;
		let desiredHeight = UIScreen.mainScreen().bounds.height * 0.8;
		dialogContentView.setupAs(navigationParam);
		dialogContentView.delegate = self;
		dialogContentView.frame = CGRectMake((UIScreen.mainScreen().bounds.width - dialogContentView.frame.width) / 2,
		                               1000,
		                               dialogContentView.frame.width,
		                               desiredHeight);
		dialogContentView.layoutSubviews();
		self.navigationController!.view.addSubview(self.fadingView);
		self.fadingView.addSubview(self.dialogContentView);
		UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
			self.dialogContentView.frame.origin.y = (UIScreen.mainScreen().bounds.height - desiredHeight) / 2;
			self.fadingView.alpha = 1;
			}, completion: {result in
				
		});
	}
	
	func closeDialog() {
		UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
			self.fadingView.alpha = 0;
			self.dialogContentView.frame.origin.y = 1000;
			}, completion: {result in
				self.fadingView.removeFromSuperview();
				self.dialogContentView.removeFromSuperview();
		})
		
	}
}

