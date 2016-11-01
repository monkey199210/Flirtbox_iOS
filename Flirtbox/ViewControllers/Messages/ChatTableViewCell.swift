//
//  ChatTableViewCell.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 10.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit
protocol ChatTableViewCellDelegate{
	func imageTapped();
}
class ChatTableViewCell: UITableViewCell {
	
	var delegate: ChatTableViewCellDelegate!;
	
    override func awakeFromNib() {
        super.awakeFromNib()
		self.contentView.backgroundColor = UIColor.clearColor()
		self.avatar.layer.borderWidth = 0.0
		self.avatar.layer.masksToBounds = false
		self.avatar.layer.borderColor = UIColor.clearColor().CGColor
		self.avatar.layer.cornerRadius = self.avatar.frame.size.width/2.0
		self.avatar.clipsToBounds = true
		let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatTableViewCell.imageTapped(_:)));
		tapRecognizer.numberOfTapsRequired = 1;
		self.avatar.userInteractionEnabled = true;
		self.avatar.addGestureRecognizer(tapRecognizer);
        // Initialization code
    }
	
	func imageTapped(recognizer: UIGestureRecognizer){
		self.delegate.imageTapped();
	}

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
	
	func configureWithData(text: String, timeStr : String, usersAvatar: String?){
		self.message.text = text
		self.backgroundColor = UIColor.clearColor()
		self.time.text = String.getChatTimeString(timeStr);
		var imageUrl: String
		if let avatarImage = usersAvatar {
			imageUrl = avatarImage.hasPrefix("http") ? avatarImage : FBNet.PROFILE_PIC_SMALL + avatarImage
		}else{
			imageUrl = FBNet.PROFILE_DEFAULT_PIC
		}
		if let url = NSURL(string: imageUrl) {
			self.avatar.nk_cancelLoading()
			self.avatar.nk_setImageWith(url)
		}
		self.setNeedsLayout()
		self.layoutIfNeeded()
	}

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var time: UILabel!
}
