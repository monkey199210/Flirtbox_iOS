//
//  ChangePassViewController.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 08.01.16.
//  Copyright © 2016 flirtbox. All rights reserved.
//

import UIKit
import Bond

class ChangePassViewController: UIViewController {

	@IBOutlet weak var changePasswordLabel: UILabel!
    weak var settingsViewController: SettingsViewController?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		changePasswordLabel.text = "_CHANGE_PASSWORD".localized;
		newPassword.placeholder = "_NEW_PASSWORD".localized;
		confirmField.placeholder = "_CONFIRM_PASS".localized;
        self.checkSubmitButton()
        self.newPassword.bnd_text.observe { (text) -> Void in
            self.checkSubmitButton()
        }
        self.confirmField.bnd_text.observe { (text) -> Void in
            self.checkSubmitButton()
        }
    }

    // MARK: - Outlets
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    
    // MARK: - Actions
    @IBAction func cancelAction(sender: AnyObject) {
        self.close()
    }
    @IBAction func submitAction(sender: AnyObject) {
        Net.changePassword(self.newPassword.text!)
        self.close()
    }
    
    // MARK: - Helper methods
    private func checkSubmitButton() {
        self.submitButton.enabled = self.newPassword.text?.length > 0 && self.confirmField.text?.length > 0 && self.newPassword.text == self.confirmField.text
    }
    private func close() {
        self.settingsViewController?.closeNotiffMedium()
        UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.alpha = 0.0
            }, completion:{ (_) -> Void in
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
        })
    }
}
