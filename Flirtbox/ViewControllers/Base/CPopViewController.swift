//
//  CPopViewController.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 06.01.16.
//  Copyright © 2016 flirtbox. All rights reserved.
//

import UIKit

class CPopViewController: UIViewController {
    private var popUps: [(closeButton: UIButton,popUp: UIView)] = []
    func showCustomPopUp(popUp: UIView) {
        self.view.endEditing(true)
        if popUps.count > 0 {
            UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
                self.popUps.last!.closeButton.alpha = 0.0
                self.popUps.last!.popUp.alpha = 0.0
                }, completion:{(_) -> Void in
            })
        }
        let closeButton = UIButton(type: .Custom)
        closeButton.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
        closeButton.addTarget(self, action: #selector(CPopViewController.closeAction(_:)), forControlEvents: .TouchUpInside)
        closeButton.alpha = 0.0
        UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            closeButton.alpha = 1.0
            }, completion:{(_) -> Void in
        })
        self.view.addSubview(closeButton)
        Restraint(closeButton, .Top, .Equal, self.view, .Top).addToView(self.view)
        Restraint(closeButton, .Bottom, .Equal, self.view, .Bottom).addToView(self.view)
        Restraint(closeButton, .Leading, .Equal, self.view, .Leading).addToView(self.view)
        Restraint(closeButton, .Trailing, .Equal, self.view, .Trailing).addToView(self.view)
        self.view.addSubview(popUp)
        Restraint(popUp, .CenterX, .Equal, self.view, .CenterX).addToView(self.view)
        Restraint(popUp, .CenterY, .Equal, self.view, .CenterY, 1.0, -UIApplication.sharedApplication().statusBarFrame.height).addToView(self.view)
        Restraint(popUp, .Width,  .Equal, popUp.frame.size.width).addToView(popUp)
        Restraint(popUp, .Height,  .Equal, popUp.frame.size.height).addToView(popUp)
        UIView.appearWithScale(popUp, duration: FBoxConstants.kAnimationFastDuration, completition:nil)
        self.popUps.append((closeButton, popUp))
    }
    func closeCustomPopUp() {
        self.closeCPopUp()
    }
    @objc private func closeAction(button: UIButton) {
        self.closeCPopUp()
    }
    private func closeCPopUp() {
        UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.popUps.last!.closeButton.alpha = 0.0
            self.popUps.last!.popUp.alpha = 0.0
            }, completion:{(_) -> Void in
                self.popUps.last!.closeButton.removeFromSuperview()
                self.popUps.last!.popUp.removeFromSuperview()
                self.popUps.removeLast()
                if self.popUps.count > 0 {
                    UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
                        self.popUps.last!.closeButton.alpha = 1.0
                        self.popUps.last!.popUp.alpha = 1.0
                        }, completion:{(_) -> Void in
                    })
                }
        })
    }
}
