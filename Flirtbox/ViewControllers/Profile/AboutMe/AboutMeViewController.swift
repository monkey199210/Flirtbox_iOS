 //
//  AboutMeViewController.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 07.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit
import LGAlertView

class AboutMeViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UserInfoDelegate {

    var user: FBSearchedUser?
    var userDetailed: FBUser?
    
    weak var profileViewController: ProfileViewController?
    
    // MARK: - Lifecycle
	
    private let sexualitiesForMen = ["_SEXUALITY_STRAIGHT".localized, "_SEXUALITY_BI".localized, "_SEXUALITY_GAY".localized]
    private let sexualitiesForFemale = ["_SEXUALITY_STRAIGHT".localized, "_SEXUALITY_BI".localized, "_SEXUALITY_GAY".localized]
    private var signGender = true
    private var isSexualityPicker = false
    private var sexualities: Array<String> {
        get {
            if signGender {
                return sexualitiesForMen
            }else{
                return sexualitiesForFemale
            }
        }
    }
	private var userGender : String = "m";
    deinit {
        FBEvent.onProfileReceived().removeListener(self)
        FBEvent.onAuthenticated().removeListener(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
		self.initUserInfoViews();
        whiteView.layer.cornerRadius = 5.0
        whiteView.layer.masksToBounds = true
		self.changeDescriptionButton.setTitle("_EDIT".localized, forState: .Normal);
        self.setDescription("")
        if self.user == nil && self.userDetailed == nil {
            if AuthMe.isAuthenticated() {
                self.configure()
            }
            FBEvent.onAuthenticated().listen(self) { [unowned self] (isAuthenticated) -> Void in
                if isAuthenticated {
                    self.configure()
                }else{
                    self.setDescription("")
                    self.changeDescriptionButton.setTitle("_EDIT".localized, forState: .Normal)
                }
            }
        }else{
            self.emptyDescription.alpha = 0.0
            self.changeDescriptionButton.userInteractionEnabled = false

            if let user = self.profileViewController?.userDetailed {
                configureWithUser(user)
            }
        }
    }
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews();
	}
    func updateWithUser(user: FBUser) {
        configureWithUser(user)
    }
    private func configure() {
        if AuthMe.isAuthenticated() {
            if let user = UserProfile.currentUser() {
                configureWithUser(user)
            }
            FBEvent.onProfileReceived().listen(self, callback: { [unowned self] (user) -> Void in
                self.configureWithUser(user)
            })
        }
    }
    private func configureWithUser(user: FBUser) {
//	self.userDetailed = user;
        let descr = user.general.description
        var trimmedDescription = descr.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        trimmedDescription = descr.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\n\r"))
        if trimmedDescription.length > 0 {
            self.setDescription(trimmedDescription)
        }
        if user.general.sexuality?.length > 0 {
			self.sexualityView.configureWith("profileSex", text: "_SEXUALITY".localized, buttonText: user.general.sexuality!);
        }else if self.user != nil || self.userDetailed != nil {
            self.hideSexualityField()
        }
        if user.appearance.height.length > 0 {
			self.heightView.configureWith("profileHeight", text: "_HEIGHT".localized, buttonText: user.appearance.height);
        }else if self.user != nil || self.userDetailed != nil {
            self.hideHeightField()
        }
        if user.appearance.eyecolour.length > 0 {
			self.eyecolorView.configureWith("profileEye", text: "_EYECOLOUR".localized, buttonText: user.appearance.eyecolour);
        }else if self.user != nil || self.userDetailed != nil {
            self.hideEyeColourField()
        }
        if user.appearance.hairstyle.length > 0 {
			self.hairstyleView.configureWith("profileHair", text: "_HAIRSTYLE".localized, buttonText: user.appearance.hairstyle);
        }else if self.user != nil || self.userDetailed != nil {
            self.hideHairStyleField()
        }
        if user.appearance.bodyshape.length > 0 {
			self.bodyshapeView.configureWith("profileBody", text: "_BODYSHAPE".localized, buttonText: user.appearance.bodyshape);
        }else if self.user != nil || self.userDetailed != nil {
            self.hideBodyshapeField()
        }
        if user.life.education.length > 0 {
			self.educationView.configureWith("profileEducation", text: "_EDUCATION".localized, buttonText: user.life.education, hideSeparator: true);
        }else if self.user != nil || self.userDetailed != nil {
            self.hideEducationField()
        }
        if user.general.country.length > 0 {
			self.countryView.configureWith("profileCountry", text: "_COUNTRY".localized, buttonText: user.general.country);
        }else if self.user != nil || self.userDetailed != nil {
            self.hideCountryField()
        }
        if user.general.originalCountry.length > 0 {
			self.originalCountryView.configureWith("profileOriginalCountry", text: "_HOME_COUNTRY".localized, buttonText: user.general.originalCountry);
        }else if self.user != nil || self.userDetailed != nil {
            self.hideOriginalCountryField()
        }
        if user.general.town?.length > 0 {
			self.townView.configureWith("profileTown", text: "_TOWN".localized, buttonText: user.general.town);
        }else if self.user != nil || self.userDetailed != nil {
            self.hideTownField()
        }
        if user.general.age?.length > 0 {
			self.ageView.configureWith("profileAge", text: "_AGE".localized, buttonText: user.general.age);
        }else if self.user != nil || self.userDetailed != nil {
            self.hideAgeField()
        }
        if user.life.profession.length > 0 {
			self.professionView.configureWith("profileProfession", text: "_PROFESSION".localized, buttonText: user.life.profession);
        }else if self.user != nil || self.userDetailed != nil {
            self.hideProfessionField()
        }
		self.layoutUserInfo()
		self.whiteViewHeightConstraint.constant = self.getCalculatedHeight();
		
		self.view.layoutSubviews();
		self.userGender = user.general.gender ?? "m";
        if user.general.gender == "m" {
            self.signGender = true
        }else{
            self.signGender = false
        }
    }
    
    // MARK: - Actions
	
    @IBAction func changeDescriptionAction(sender: AnyObject) {
        openTextEditing(Net.SingleProfileItems.DESCRIPTION.rawValue, title: "_ABOUT_ME".localized)
    }
    @IBAction func enterDescriptionAction(sender: AnyObject) {
        openTextEditing(Net.SingleProfileItems.DESCRIPTION.rawValue, title: "_ABOUT_ME".localized)
    }
    
    private func openTextEditing(item: String, title: String) {
        if self.user != nil || self.userDetailed != nil {
            return
        }
        let textView = UITextView(frame: CGRectMake(0, 0, 260, 100))
        let font = UIFont(name: "Roboto", size: 13.0)
        textView.font = font
        textView.autocapitalizationType = .Sentences
        if item == Net.SingleProfileItems.AGE.rawValue {
            textView.keyboardType = .NumberPad
        }
        if AuthMe.isAuthenticated() {
            if let user = UserProfile.currentUser() {
                if item == Net.SingleProfileItems.DESCRIPTION.rawValue {
                    let descr = user.general.description
                    var trimmedDescription = descr.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    trimmedDescription = descr.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\n\r"))
                    if trimmedDescription.length > 0 {
                        textView.text = trimmedDescription
                    }
                }else if item == Net.SingleProfileItems.AGE.rawValue && user.general.age?.length > 0 {
                    textView.text = user.general.age
                }else if item == Net.SingleProfileItems.TOWN.rawValue && user.general.town?.length > 0 {
                    textView.text = user.general.town
                }else if item == Net.SingleProfileItems.COUNTRY.rawValue && user.general.country.length > 0 {
                    textView.text = user.general.country
                }else if item == Net.SingleProfileItems.ORIGINALCOUNTRY.rawValue && user.general.originalCountry.length > 0 {
                    textView.text = user.general.originalCountry
                }else{
                    GoogleAnalitics.send(GoogleAnalitics.OwnAbout.Category, action: GoogleAnalitics.OwnAbout.ADD, label: item)
                }
            }
        }
        textView.textColor = UIColor(red:0.41, green:0.43, blue:0.44, alpha:1)
        let datePicker = LGAlertView(viewStyleWithTitle: title, message: "", view: textView, buttonTitles: ["_SUBMIT".localized.uppercaseString], cancelButtonTitle: "_CANCEL".localized.uppercaseString, destructiveButtonTitle: nil, actionHandler: { [weak textView] (alertView, name, index) -> Void in
            let description = textView?.text
            if let descr = description where descr.length > 0 {
                GoogleAnalitics.send(GoogleAnalitics.OwnAbout.Category, action: GoogleAnalitics.OwnAbout.UPDATE, label: item)
                Net.updateProfile(item, value: descr).onSuccess(callback: { (_) -> Void in
                    if item == Net.SingleProfileItems.DESCRIPTION.rawValue {
                        self.setDescription(descr)
                    }else if item == Net.SingleProfileItems.AGE.rawValue {
                        if descr.length > 0 {
							self.ageView.configureWithValue(descr);
                        }
                    }else if item == Net.SingleProfileItems.TOWN.rawValue {
                        if descr.length > 0 {
							self.townView.configureWithValue(descr)
                        }
                    }else if item == Net.SingleProfileItems.COUNTRY.rawValue {
                        if descr.length > 0 {
							self.countryView.configureWithValue(descr);
                        }
                    }else if item == Net.SingleProfileItems.ORIGINALCOUNTRY.rawValue {
                        if descr.length > 0 {
							self.originalCountryView.configureWithValue(descr);
                        }
                    }
                })
            }
            }, cancelHandler: { (alertView,result) -> Void in
                
            }, destructiveHandler: nil)
        datePicker.showAnimated(true, completionHandler: {
            textView.becomeFirstResponder()
        })
    }
    private func openTextFieldEditing(item: String, keyboardType: UIKeyboardType, title: String) {
        let textField = UITextField(frame: CGRectMake(0, 0, 260, 21))
        let font = UIFont(name: "Roboto", size: 13.0)
        textField.font = font
        textField.keyboardType = keyboardType
        textField.textColor = UIColor(red:0.41, green:0.43, blue:0.44, alpha:1)
        let datePicker = LGAlertView(viewStyleWithTitle: "_ABOUT_ME".localized, message: "", view: textField, buttonTitles: ["_SUBMIT".localized.uppercaseString], cancelButtonTitle: "_CANCEL".localized.uppercaseString, destructiveButtonTitle: nil, actionHandler: { [weak textField] (alertView, name, index) -> Void in
            let description = textField?.text
            if let descr = description where descr.length > 0 {
                Net.updateProfile(item, value: descr).onSuccess(callback: { (_) -> Void in
                    if item == Net.SingleProfileItems.HEIGHT.rawValue {
						self.heightView.configureWithValue(descr);
                    }
                })
            }
            }, cancelHandler: { (alertView,result) -> Void in
                
            }, destructiveHandler: nil)
        datePicker.showAnimated(true, completionHandler: {
            textField.becomeFirstResponder()
        })
    }
    private func openWithValues(array: [FBLocalValue], title: String, item: String) {
        self.isSexualityPicker = false
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        self.values = array
        let alertPicker = LGAlertView(viewStyleWithTitle: title, message: "", view: picker, buttonTitles: ["_SUBMIT".localized.capitalizedString], cancelButtonTitle: "_CANCEL".localized.capitalizedString, destructiveButtonTitle: nil, actionHandler: { [weak self] (alertView, name, index) -> Void in
            if let descr = self?.values[picker.selectedRowInComponent(0)] {
                var value: AnyObject?
                let correctValue = descr.text.stringByReplacingOccurrencesOfString("'", withString: "\'")
                if item == Net.TagProfileItems.LANGUAGES.rawValue {
                    value = [correctValue]
                }else{
                    value = correctValue
                }
				if(item == Net.SingleProfileItems.SEXUALITY.rawValue){
					var fbSex: Sexuality? = nil
						switch(picker.selectedRowInComponent(0)){
						case 0:
							fbSex = self?.userGender == "m" ? .Msf : .Fsm
						case 1:
							fbSex = self?.userGender == "m" ? .Msmf : .Fsmf
						case 2:
							fbSex = self?.userGender == "m" ? .Msm : .Fsf
						default:
							break
						}
					value = fbSex?.rawValue;
				}
                GoogleAnalitics.send(GoogleAnalitics.OwnAbout.Category, action: GoogleAnalitics.OwnAbout.UPDATE, label: item)
                Net.updateProfile(item, value: value).onSuccess(callback: { (_) -> Void in
                    switch item {
                    case Net.SingleProfileItems.BODYSHAPE.rawValue:
						self?.bodyshapeView.configureWithValue(descr.text);
                    case Net.SingleProfileItems.HAIRSTYLE.rawValue:
						self?.hairstyleView.configureWithValue(descr.text);
                    case Net.SingleProfileItems.EYECOLOUR.rawValue:
						self?.eyecolorView.configureWithValue(descr.text);
                    case Net.SingleProfileItems.EDUCATION.rawValue:
						self?.educationView.configureWithValue(descr.text);
                    case Net.SingleProfileItems.PROFESSION.rawValue:
						self?.professionView.configureWithValue(descr.text);
                    case Net.SingleProfileItems.SEXUALITY.rawValue:
						GoogleAnalitics.send(GoogleAnalitics.OwnAbout.Category, action: GoogleAnalitics.OwnAbout.UPDATE, label: Net.SingleProfileItems.SEXUALITY.rawValue)
						self?.sexualityView.configureWithValue(descr.text);
                    case Net.SingleProfileItems.HEIGHT.rawValue:
						self?.heightView.configureWithValue(descr.text);
                    default:
                        break;
                    }
                })
            }
            }, cancelHandler: { (alertView,result) -> Void in
                
            }, destructiveHandler: nil)
        alertPicker.showAnimated(true, completionHandler: nil)
    }
    
    // MARK: - Outlets
    @IBOutlet weak var whiteView: UIView!
    @IBOutlet weak var userDescription: UILabel!
    @IBOutlet weak var emptyDescription: UILabel!
    @IBOutlet weak var enterDescriptionButton: UIButton!
    @IBOutlet weak var changeDescriptionButton: UIButton!
	@IBOutlet weak var whiteViewHeightConstraint: NSLayoutConstraint!
    
	
	
    // MARK: - Helper methods
    private func setDescription(description: String) {
        if description.length > 0 {
            userDescription.text = description
            emptyDescription.hidden = true
            enterDescriptionButton.hidden = true
            changeDescriptionButton.hidden = false
        }else{
            userDescription.text = " "
            emptyDescription.hidden = false
            enterDescriptionButton.hidden = false
            changeDescriptionButton.hidden = true
        }
    }
    
    // MARK: - UIPickerViewDataSource
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.isSexualityPicker {
            return sexualities.count
        }else{
            return values.count
        }
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // MARK: - UIPickerViewDelegate
    private var values: [FBLocalValue] = []
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if self.isSexualityPicker {
            return sexualities[row]
        }else{
            return values[row].text
        }
    }
	
	//MARK: -User Outlets
	
	var sexualityView: UserInfoView!
	var ageView: UserInfoView!
	var townView: UserInfoView!
	var countryView: UserInfoView!
	var originalCountryView: UserInfoView!
	var professionView: UserInfoView!
	var heightView: UserInfoView!
	var bodyshapeView: UserInfoView!
	var hairstyleView: UserInfoView!
	var eyecolorView: UserInfoView!
	var educationView: UserInfoView!
	
	//MARK: -User info stuff
	func initUserInfoViews(){
		sexualityView = UserInfoView(imagename: "profileSex",
		                             text: "_SEXUALITY".localized,
		                             frame: CGRectMake(0, 0, self.whiteView.frame.width, 60),
		                             type: .Sexuality, delegate: self);
		self.whiteView.addSubview(sexualityView);
		ageView = UserInfoView(imagename:"profileAge",
		                       text: "_AGE".localized,
		                       frame: CGRectMake(0,sexualityView.frame.maxY, self.whiteView.frame.width, 60),
		                       type: .Age, delegate: self);
		self.whiteView.addSubview(ageView);
		townView = UserInfoView(imagename:"profileTown",
		                        text: "_TOWN".localized,
		                        frame: CGRectMake(0,ageView.frame.maxY, self.whiteView.frame.width, 60),
		                        type: .Town, delegate: self);
		self.whiteView.addSubview(townView);
		countryView = UserInfoView(imagename: "profileCountry",
		                           text: "_COUNTRY".localized,
		                           frame: CGRectMake(0,townView.frame.maxY, self.whiteView.frame.width, 60),
		                           type: .Country, delegate: self);
		self.whiteView.addSubview(countryView);
		originalCountryView = UserInfoView(imagename: "profileOriginalCountry",
		                                   text: "_HOME_COUNTRY".localized,
		                                   frame: CGRectMake(0,countryView.frame.maxY, self.whiteView.frame.width, 60),
		                                   type: .OriginalCountry, delegate: self);
		self.whiteView.addSubview(originalCountryView);
		professionView = UserInfoView(imagename: "profileProfession",
		                              text: "_PROFESSION".localized,
		                              frame: CGRectMake(0,originalCountryView.frame.maxY, self.whiteView.frame.width, 60),
		                              type: .Profession, delegate: self);
		self.whiteView.addSubview(professionView);
		heightView = UserInfoView(imagename: "profileHeight",
		                          text: "_HEIGHT".localized,
		                          frame: CGRectMake(0,professionView.frame.maxY, self.whiteView.frame.width, 60),
								  type: .Height, delegate: self);
		self.whiteView.addSubview(heightView);
		bodyshapeView = UserInfoView(imagename: "profileBody",
		                             text: "_BODYSHAPE".localized,
		                             frame: CGRectMake(0, heightView.frame.maxY, self.whiteView.frame.width, 60),
		                             type: .Bodyshape, delegate: self);
		self.whiteView.addSubview(bodyshapeView);
		hairstyleView = UserInfoView(imagename: "profileHair",
		                             text: "_HAIRSTYLE".localized,
		                             frame: CGRectMake(0, bodyshapeView.frame.maxY, self.whiteView.frame.width, 60),
		                             type: .Hairstyle, delegate: self);
		self.whiteView.addSubview(hairstyleView);
		eyecolorView = UserInfoView(imagename: "profileEye",
		                            text: "_EYECOLOUR".localized,
		                            frame: CGRectMake(0,hairstyleView.frame.maxY, self.whiteView.frame.width, 60),
		                            type: .Eyecolor, delegate: self);
		self.whiteView.addSubview(eyecolorView);
		educationView = UserInfoView(imagename: "profileEducation",
		                             text: "_EDUCATION".localized,
		                             frame: CGRectMake(0,eyecolorView.frame.maxY, self.whiteView.frame.width, 60),
		                             type: .Education, delegate: self);
		self.whiteView.addSubview(educationView);
	}
	
	func layoutUserInfo(){
		for (var i = 1; i<self.whiteView.subviews.count; i++){
			self.whiteView.subviews[i].placeDownAfter(self.whiteView.subviews[i - 1], delta: 0);
		}
	}
	
	//MARK: Userinfo delegate
	
	func onUserInfoChangeRequested(type: eUserInfo) {
		if self.user != nil || self.userDetailed != nil {
			return
		}
		switch type {
		case .Sexuality:
			Net.localValues(Net.SingleProfileItems.SEXUALITY.rawValue, animated: true, category: nil, gender: self.userGender).onSuccess { (values) -> Void in
				self.openWithValues(values, title: "_SEXUALITY".localized, item: Net.SingleProfileItems.SEXUALITY.rawValue)
			}
		case .Age:
			if AuthMe.isAuthenticated() {
				if let user = UserProfile.currentUser() {
					self.view.endEditing(true)
					let picker = UIDatePicker()
					picker.datePickerMode = .Date
					let maxYear = NSDate().year() - 17
					let month = NSDate().month() > 9 ? "0\(NSDate().month())" : "\(NSDate().month())"
					let day = NSDate().day() > 9 ? "0\(NSDate().day())" : "\(NSDate().day())"
					let maxDate = NSDate(fromString:  "\(maxYear)-\(month)-\(day)", format: .ISO8601(nil))
					picker.maximumDate = maxDate
					if let birthDate = user.general.dateOfBirth {
						picker.date = NSDate(fromString:  birthDate, format: .ISO8601(nil))
						GoogleAnalitics.send(GoogleAnalitics.OwnAbout.Category, action: GoogleAnalitics.OwnAbout.UPDATE, label: Net.SingleProfileItems.AGE.rawValue)
					}else{
						GoogleAnalitics.send(GoogleAnalitics.OwnAbout.Category, action: GoogleAnalitics.OwnAbout.ADD, label: Net.SingleProfileItems.AGE.rawValue)
					}
					let datePicker = LGAlertView(viewStyleWithTitle: "_DATE_OF_BIRTH".localized, message: "", view: picker, buttonTitles: ["OK"], cancelButtonTitle: nil, destructiveButtonTitle: nil, actionHandler: { [weak picker] (alertView, name, index) -> Void in
						if let selectedDate = picker?.date {
							let dateSting = selectedDate.toString(format: .Custom("yyyy-MM-dd"))
							Net.updateProfile(Net.SingleProfileItems.AGE.rawValue, value: dateSting).onSuccess(callback: { (_) -> Void in
							})
						}
						}, cancelHandler: nil, destructiveHandler: nil)
					datePicker.showAnimated(true, completionHandler: nil)
				}
			}
		case .Town:
			openTextEditing(Net.SingleProfileItems.TOWN.rawValue, title: "_TOWN".localized);
		case .Country:
			openTextEditing(Net.SingleProfileItems.COUNTRY.rawValue, title: "_COUNTRY".localized);
		case .OriginalCountry:
			openTextEditing(Net.SingleProfileItems.ORIGINALCOUNTRY.rawValue, title: "_HOME_COUNTRY".localized);
		case .Profession:
			Net.localValues(Net.SingleProfileItems.PROFESSION.rawValue).onSuccess { (values) -> Void in
				self.openWithValues(values, title: "_PROFESSION".localized, item: Net.SingleProfileItems.PROFESSION.rawValue)
			};
		case .Bodyshape:
			Net.localValues(Net.SingleProfileItems.BODYSHAPE.rawValue).onSuccess { (values) -> Void in
				self.openWithValues(values, title: "_BODYSHAPE".localized, item: Net.SingleProfileItems.BODYSHAPE.rawValue)
			};
		case .Height:
			Net.localValues(Net.SingleProfileItems.HEIGHT.rawValue).onSuccess { (values) -> Void in
				self.openWithValues(values, title: "_HEIGHT".localized, item: Net.SingleProfileItems.HEIGHT.rawValue)
			}
		case .Hairstyle:
			Net.localValues(Net.SingleProfileItems.HAIRSTYLE.rawValue).onSuccess { (values) -> Void in
				self.openWithValues(values, title: "_HAIRCOLOUR".localized, item: Net.SingleProfileItems.HAIRSTYLE.rawValue)
			}
		case .Education:
			Net.localValues(Net.SingleProfileItems.EDUCATION.rawValue).onSuccess { (values) -> Void in
				self.openWithValues(values, title: "_EDUCATION".localized, item: Net.SingleProfileItems.EDUCATION.rawValue)
			};
		case .Eyecolor:
			Net.localValues(Net.SingleProfileItems.EYECOLOUR.rawValue).onSuccess { (values) -> Void in
				self.openWithValues(values, title: "_EYECOLOUR".localized, item: Net.SingleProfileItems.EYECOLOUR.rawValue)
			};
		default:
			break;
		}
	}
}
