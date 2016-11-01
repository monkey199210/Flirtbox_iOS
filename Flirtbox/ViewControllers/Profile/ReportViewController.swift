//
//  ReportViewController.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 11.12.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit
import LGAlertView
import Bond

class ReportViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    weak var profileViewController: ProfileViewController?
    private var selectedCategory: (String, ReportType)? {
        didSet {
            if let cat = selectedCategory {
                reportCategoryButton.setTitle(cat.0, forState: .Normal)
            }
        }
    }
    private let categories: [(String, ReportType)] = [("_REPORT_OPTION_1".localized, .OffensivePicture), ("_REPORT_OPTION_2".localized, .StolenOrFakePicture), ("_REPORT_OPTION_3".localized, .AdvertisingOrCommercialInterests), ("_REPORT_OPTION_4".localized, .Scammer), ("_REPORT_OPTION_5".localized, .NastyRudeBehaviour), ("_REPORT_OPTION_6".localized, .InconsistentProfile), ("_REPORT_OPTION_7".localized, .Other)]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedCategory = categories[0]
        self.reportText.bnd_text.map { (text) -> Bool in
            return text?.length > 0
        }.bindTo(self.submitButton.bnd_enabled)
    }

    // MARK: - Outlets
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var reportText: UITextView!
    @IBOutlet weak var reportCategoryButton: UIButton!
    
    // MARK: - Actions
    @IBAction func reportCategoryAction(sender: AnyObject) {
        self.view.endEditing(true)
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        let alertPicker = LGAlertView(viewStyleWithTitle: "_REPORT".localized, message: "", view: picker, buttonTitles: ["OK"], cancelButtonTitle: "_CANCEL".localized, destructiveButtonTitle: nil, actionHandler: { [weak self, unowned picker] (alertView, name, index) -> Void in
            let item = self?.categories[picker.selectedRowInComponent(0)]
            self?.selectedCategory = item
            self?.reportText.becomeFirstResponder()
            }, cancelHandler: { [weak self] (alertView,result) -> Void in
                self?.reportText.becomeFirstResponder()
            }, destructiveHandler: nil)
        alertPicker.showAnimated(true, completionHandler: nil)
    }
    @IBAction func submitAction(sender: AnyObject) {
        if let username = self.profileViewController?.user?.username, let cat = selectedCategory {
            GoogleAnalitics.send(GoogleAnalitics.OthersProfile.Category, action: GoogleAnalitics.OthersProfile.REPORT)
            Net.report(username, categoryId: cat.1, message: reportText.text)
        }
        close()
    }
    @IBAction func cancelAction(sender: AnyObject) {
        close()
    }
    
    // MARK: - Helper methods
    func openReportText() {
        reportText.becomeFirstResponder()
    }
    private func close() {
        self.profileViewController?.closeAddFave()
        UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.alpha = 0.0
            }, completion:{ (_) -> Void in
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
        })
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
        label.text = categories[row].0
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
}
