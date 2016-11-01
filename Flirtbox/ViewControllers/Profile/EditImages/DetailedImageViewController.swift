//
//  DetailedImageViewController.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 08.12.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit
import LGAlertView

class DetailedImageViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate {

    // MARK: - Lifecycle
    var image: FBPicture?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let img = image {
            if let url = NSURL(string: img.getUrl()) {
                picture.nk_cancelLoading()
                picture.nk_setImageWith(url)
            }
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var picture: UIImageView!
    
    // MARK: - Actions
    @IBAction func editDescriptionAction(sender: AnyObject) {
        let textView = UITextView(frame: CGRectMake(0, 0, 260, 100))
        let font = UIFont(name: "Roboto", size: 13.0)
        textView.font = font
        textView.autocapitalizationType = .Sentences
        textView.textColor = UIColor(red:0.41, green:0.43, blue:0.44, alpha:1)
        let datePicker = LGAlertView(viewStyleWithTitle: "_DESCRIPTION".localized, message: "", view: textView, buttonTitles: ["_SUBMIT".localized.uppercaseString], cancelButtonTitle: "_CANCEL".localized.uppercaseString, destructiveButtonTitle: nil, actionHandler: { [weak textView] (alertView, name, index) -> Void in
            let description = textView?.text
            if let img = self.image, let descr = description where descr.length > 0, let ratable = Int(img.ratable) {
				
				Net.updatePicture(img.picid, ratable: ratable, visibility: Visibility.fromString(img.visibility), description: description!);//Net.updatePictureDescription(img.picid, description: descr)
            }
            }, cancelHandler: { (alertView,result) -> Void in
                
            }, destructiveHandler: nil)
        datePicker.showAnimated(true, completionHandler: {
            textView.becomeFirstResponder()
        })
    }
    @IBAction func closeAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func changeRateAction(sender: AnyObject) {
        if let img = image, let ratable = Int(img.ratable) {
			
            Net.updatePicture(img.picid, ratable: ratable , visibility: Visibility.fromString(img.visibility)).onSuccess(callback: { (_) -> Void in
                FBEvent.pictChanged(true)
            })
//            if !rtb {
//                image!.ratable = "1"
//            }else{
//                image!.ratable = "0"
//            }
			image?.ratable = "\(ratable)"
        }
    }
    @IBAction func changeVisibilityAction(sender: AnyObject) {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        let datePicker = LGAlertView(viewStyleWithTitle: "Visibility", message: "", view: picker, buttonTitles: ["_SUBMIT".localized.uppercaseString], cancelButtonTitle: "_CANCEL".localized.uppercaseString, destructiveButtonTitle: nil, actionHandler: { [weak self] (alertView, name, index) -> Void in
            if let img = self?.image, let ratable = Int(img.ratable) {
                let rtb = ratable == 0 ? false : true
                let visibilityString = String(picker.selectedRowInComponent(0) + 1)
                Net.updatePicture(img.picid, ratable: ratable, visibility: Visibility.fromString(visibilityString), description: img.description).onSuccess(callback: { (_) -> Void in
                    FBEvent.pictChanged(true)
                })
            }
            }, cancelHandler: { (alertView,result) -> Void in
                
            }, destructiveHandler: nil)
        datePicker.showAnimated(true, completionHandler: nil)
    }
    @IBAction func deletePictureAction(sender: AnyObject) {
        UIAlertView(title: "_PICTURE_DELETE_DIALOG_TITLE".localized, message: "_REALLY_DELETE_PICTURE".localized, delegate: self, cancelButtonTitle: "_CANCEL".localized.uppercaseString, otherButtonTitles: "OK").show()
    }
    
    // MARK: - UIPickerViewDataSource
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // MARK: - UIPickerViewDelegate
    private let visibilityArray = ["_ANYONE".localized, "_MEMBERS".localized, "_MEMBERS_WITH_PICTURES".localized]
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return visibilityArray[row]
    }
    
    // MARK: - UIAlertViewDelegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if let img = self.image where buttonIndex == 1 {
            if let picId = Int(img.picid), let isMain = Int(img.mainpic) {
                Net.deletePicture([picId]).onSuccess(callback: { (_) -> Void in
                    if isMain > 0 {
                        UserProfile.clearMainPictUrl()
                    }
                    FBEvent.pictChanged(true)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }).onFailure(callback: { (error) -> Void in
                    UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK").show()
                })
            }
        }
    }
}
