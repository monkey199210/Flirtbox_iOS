//
//  ChatMyTableViewCell.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 10.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit
class ChatMyTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		self.backgroundColor = UIColor.clearColor()
		self.contentView.backgroundColor = UIColor.clearColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
		
        // Configure the view for the selected state
    }
	
	func configureWithData(text: String, timeStr : String){
		self.responce.text = text
		self.backgroundColor = UIColor.clearColor()
		self.time.text = String.getChatTimeString(timeStr);
		self.setNeedsLayout()
		self.layoutIfNeeded()
	}

    @IBOutlet weak var responce: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var icon: UIImageView!
}
