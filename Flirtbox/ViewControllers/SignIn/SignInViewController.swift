//
//  SignInViewController.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 05.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignInViewController.keyboardWillChangeFrame(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignInViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillChangeFrame(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            scrollBottom.constant = keyboardSize.height - 50.0
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

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == name {
            pass.becomeFirstResponder()
        }else if textField == pass {
            pass.resignFirstResponder()
        }
        return true
    }
    
    // MARK: - Outlets
    @IBOutlet weak var scrollBottom: NSLayoutConstraint!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var pass: UITextField!
    
    // MARK: - Actions
    @IBAction func closeKeyboard(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    @IBAction func lostPasswordAction(sender: AnyObject) {
        if let lostPasswordViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LostPasswordViewController") as? LostPasswordViewController {
            self.navigationController?.pushViewController(lostPasswordViewController, animated: true)
        }
    }
    @IBAction func signInAction(sender: AnyObject) {
        FBoxHelper.getMainController()?.closeSignUp()
    }
    @IBAction func backAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
