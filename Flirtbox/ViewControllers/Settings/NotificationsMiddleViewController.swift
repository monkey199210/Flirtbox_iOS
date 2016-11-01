//
//  NotificationsMiddleViewController.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 08.01.16.
//  Copyright © 2016 flirtbox. All rights reserved.
//

import UIKit

class NotificationsMiddleViewController: UIViewController {

	@IBOutlet weak var titleLabel: UILabel!
    weak var settingsViewController: SettingsViewController?
    var isPush = false
    var isMail = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pushSwitch.on = self.isPush
        self.emailSwitch.on = self.isMail
		titleLabel.text = "_SETTINGS_NOTIFICATIONS_MEDIUM".localized;
    }
    
    // MARK: - Outlets
    @IBOutlet weak var emailSwitch: UISwitch!
    @IBOutlet weak var pushSwitch: UISwitch!
    
    // MARK: - Actions
    @IBAction func submitAction(sender: AnyObject) {
        self.settingsViewController?.submitNotificationMedium((pushSwitch.on, emailSwitch.on))
        self.close()
    }
    @IBAction func cancelAction(sender: AnyObject) {
        self.close()
    }
    
    // MARK: - Helper methods
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
