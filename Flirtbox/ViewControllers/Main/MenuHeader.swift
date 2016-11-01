//
//  MenuHeader.swift
//  Flirtbox
//
//  Created by sergey petrachkov on 23/06/16.
//  Copyright © 2016 flirtbox. All rights reserved.
//

import Foundation

class MenuHeader: UIView {
	@IBOutlet weak var usernameLabel: UILabel!
	@IBOutlet weak var userImageView: UIImageView!
	
	override func awakeFromNib() {
		super.awakeFromNib();
		userImageView.layer.borderWidth = 0.0
		userImageView.layer.masksToBounds = false
		userImageView.layer.borderColor = UIColor.clearColor().CGColor
		userImageView.layer.cornerRadius = userImageView.frame.size.width/2.0
		userImageView.clipsToBounds = true
		self.usernameLabel.userInteractionEnabled = true;
		self.userImageView.userInteractionEnabled = true;
	}

}
