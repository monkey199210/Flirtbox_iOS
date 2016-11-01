//
//  OnlineCollectionViewCell.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 08.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit

class OnlineCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var userPicture: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userLocation: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		self.userPicture.layer.borderWidth = 2.0
		self.userPicture.layer.masksToBounds = false
		self.userPicture.layer.borderColor = UIColor.whiteColor().CGColor
		self.userPicture.layer.cornerRadius = self.userPicture.frame.size.width/2.0
		self.userPicture.clipsToBounds = true
	}
	
	func initWithUser(user : FBSearchedUser){
		self.userName.text = user.username
		self.userLocation.text = user.town
		self.userPicture.image = nil;
		var imageUrl: String
		if let avatar = user.avatar {
			imageUrl = avatar.hasPrefix("http") ? avatar : FBNet.PROFILE_PIC_SMALL + avatar
		}else{
			imageUrl = FBNet.PROFILE_DEFAULT_PIC
		}
		if let url = NSURL(string: imageUrl) {
			self.userPicture.nk_cancelLoading()
			self.userPicture.nk_setImageWith(url)
		}

	}
}
