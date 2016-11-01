//
//  FeedbackViewController.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 12.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit
import LGAlertView
import Bond

class FeedbackViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate {

    private var selectedCategory: FBFeedbackCategory? {
        didSet{
            if let cat = selectedCategory {
                self.categoryButton.setTitle(cat.category, forState: .Normal)
                self.categoryButton.setTitleColor(UIColor(red:0.41, green:0.43, blue:0.44, alpha:1), forState: .Normal)
                self.checkSubmitButton()
            }
        }
    }
    private func checkSubmitButton() {
        if let _ = selectedCategory where self.categoryButton.titleLabel?.text?.length > 0 && self.messageText?.text!.length > 0 {
            self.submitButton.enabled = true
        }else{
            self.submitButton.enabled = false
        }
    }
    
    // MARK: - Lifecycle
    deinit {
        FBEvent.onMainPictChanged().removeListener(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bgImage.image = nil
        self.updateMainImage()
        FBEvent.onMainPictChanged().listen(self) { [unowned self] (_) -> Void in
            self.updateMainImage()
        }
        self.messageText.bnd_text.observe { [weak self] (_) -> Void in
            self?.checkSubmitButton()
        }
		categoryButton.setTitle("_SUBJECT".localized, forState: .Normal);
		messageText.text = "_MESSAGE".localized;
		messageText.textColor = UIColor.lightGrayColor();
		messageText.layer.cornerRadius = 5;
		messageText.clipsToBounds = true;
		submitButton.setTitle("_SUBMIT".localized.uppercaseString, forState: .Normal);
		controllerTitleLabel.text = "_FEEDBACK".localized;
		self.tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(FeedbackViewController.viewTapped(_:)));
		self.view.addGestureRecognizer(self.tapRecognizer);
    }
    private func updateMainImage() {
        UserProfile.getMainPict({ (image) -> Void in
            self.bgImage.image = image
        })
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FeedbackViewController.keyboardWillChangeFrame(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FeedbackViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated);
		NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    func keyboardWillChangeFrame(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            scrollBottom.constant = keyboardSize.height
            UIView.animateWithDuration(FBoxConstants.kAnimationDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
                self.view.layoutIfNeeded()
                }, completion:{(_) -> Void in
            })
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        scrollBottom.constant = 0.0
        UIView.animateWithDuration(FBoxConstants.kAnimationDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion:{(_) -> Void in
                
        })
    }
    
    // MARK: - Outlets
    @IBOutlet weak var messageText: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var scrollBottom: NSLayoutConstraint!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var bgImage: UIImageView!
	@IBOutlet weak var controllerTitleLabel: UILabel!
    
    // MARK: - Actions
    @IBAction func submitAction(sender: AnyObject) {
        if let cat = selectedCategory {
            if AuthMe.isAuthenticated() {
                if let user = UserProfile.currentUser() where user.general.email.email != nil {
                    Net.feedback(cat.categoryID, subject: self.categoryButton.titleLabel?.text ?? "subject", message: self.messageText.text ?? "", username: user.general.username, email: user.general.email.email!).onSuccess(callback: { (_) -> Void in
                        Drop.down("_FBMAILSENT".localized, state: .Default)
                        FBoxHelper.getMainController()?.openMenu()
                    })
                }
            }
        }
        self.view.endEditing(true)
        self.messageText.text = ""
    }
    @IBAction func selectCategory(sender: AnyObject) {
        openCategorySelector()
    }
    @IBAction func closeKeyboardAction(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    // MARK: - Helper methods
    private var categories: [FBFeedbackCategory] = []
    private func openCategorySelector() {
        self.view.endEditing(true)
        Net.feedbackCategories().onSuccess { (categories) -> Void in
            if categories.count > 0 {
                self.categories = categories
                let picker = UIPickerView()
                picker.dataSource = self
                picker.delegate = self
                let alertPicker = LGAlertView(viewStyleWithTitle: "_SUBJECT".localized, message: "", view: picker, buttonTitles: ["_YES".localized.uppercaseString], cancelButtonTitle: "_CANCEL".localized.uppercaseString, destructiveButtonTitle: nil, actionHandler: { [weak self, unowned picker] (alertView, name, index) -> Void in
                    let category = self?.categories[picker.selectedRowInComponent(0)]
                    self?.selectedCategory = category
                    }, cancelHandler: { (alertView,result) -> Void in
                        
                    }, destructiveHandler: nil)
                alertPicker.showAnimated(true, completionHandler: nil)
            }
        }
    }
    
    // MARK: - UIPickerViewDataSource
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // MARK: - UIPickerViewDelegate
    private let kPickerRowHeight: CGFloat = 70.0
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let view = UIView(frame: CGRectMake(0, 0, pickerView.frame.size.width, kPickerRowHeight))
        let label = UILabel(frame: CGRectZero)
        label.text = categories[row].category
        label.textAlignment = .Center
        let font = UIFont(name: "Roboto", size: 17.0)
        label.font = font
        label.numberOfLines = 0
        label.textColor = UIColor(red:0.38, green:0.38, blue:0.38, alpha:1)
        view.addSubview(label)
        let marginConst: CGFloat = 20.0
        Restraint(label, .Top, .Equal, view, .Top).addToView(view)
        Restraint(label, .Bottom, .Equal, view, .Bottom).addToView(view)
        Restraint(label, .Leading, .Equal, view, .Leading, 1.0, marginConst).addToView(view)
        Restraint(label, .Trailing, .Equal, view, .Trailing, 1.0, -marginConst).addToView(view)
        return view
    }
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return kPickerRowHeight
    }
	
	//MARK: - UITextViewDelegate stuff
	var tapRecognizer : UITapGestureRecognizer!;
	func viewTapped (recognizer : UIGestureRecognizer){
		self.messageText.resignFirstResponder();
	}
	func textViewDidBeginEditing(textView: UITextView) {
		if(textView.textColor == UIColor.lightGrayColor()){
			textView.text = nil;
			textView.textColor = UIColor.blackColor();
		}
	}
	func textViewDidEndEditing(textView: UITextView) {
		if(textView.text.isEmpty){
			textView.text = "_MESSAGE".localized;
			textView.textColor = UIColor.lightGrayColor();
		}
	}
}
