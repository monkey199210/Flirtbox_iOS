//
//  AboutViewController.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 12.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

	@IBOutlet weak var controllerTopLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
		self.controllerTopLabel.text = "_ABOUT_US".localized;
    }

}
