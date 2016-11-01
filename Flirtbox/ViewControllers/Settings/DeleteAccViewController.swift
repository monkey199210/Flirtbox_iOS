//
//  DeleteAccViewController.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 08.01.16.
//  Copyright © 2016 flirtbox. All rights reserved.
//

import UIKit
import Bond

class DeleteAccViewController: UIViewController {

	@IBOutlet weak var warningLabel: UILabel!
	@IBOutlet weak var deleteAccountLabel: UILabel!
    weak var settingsViewController: SettingsViewController?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		deleteAccountLabel.text = "_DELETE_PROFILE".localized;
		warningLabel.text = "_DELETE_ACCOUNT_WARNING".localized;
		passwordField.placeholder = "_PASSWORD".localized;
        self.checkSubmitButton()
        self.passwordField.bnd_text.observe { (text) -> Void in
            self.checkSubmitButton()
        }
    }

    // MARK: - Outlets
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var passwordField: UITextField!
    
    // MARK: - Actions
    @IBAction func cancelAction(sender: AnyObject) {
        self.close()
    }
    @IBAction func submitAction(sender: AnyObject) {
        if AuthMe.isAuthenticated() {
            if let user = UserProfile.currentUser() {
                Net.checkPass(user.general.username, password: self.passwordField.text!).onSuccess(callback: { (authResponce) -> Void in
                    if authResponce.error == nil && authResponce.access_token != nil {
                        Net.deleteMe(self.passwordField.text!).onSuccess { (_) -> Void in
                            AuthMe.logout()
                            }.onFailure { (error) -> Void in
                                UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK").show()
                        }
                    }else if authResponce.error_description != nil {
                        UIAlertView(title: "Error", message: authResponce.error_description!, delegate: nil, cancelButtonTitle: "OK").show()
                    }
                }).onFailure(callback: { (error) -> Void in
                    UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK").show()
                })
            }
        }
        self.close()
    }
    
    // MARK: - Helper methods
    private func checkSubmitButton() {
        self.submitButton.enabled = self.passwordField.text?.length > 0
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
