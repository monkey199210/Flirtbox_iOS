//
//  EmptyListCell.swift
//  Flirtbox
//
//  Created by sergey petrachkov on 14/06/16.
//  Copyright © 2016 flirtbox. All rights reserved.
//

import Foundation

class EmptyCollectionCell: UICollectionViewCell{
	var textLabel : UILabel!;
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder);
		
	}
	override init(frame: CGRect) {
		super.init(frame: frame);
		self.textLabel = UILabel(frame: self.frame);
		self.textLabel.numberOfLines = 0;
		self.textLabel?.textAlignment = .Center;
		self.textLabel?.text = "_LIST_EMPTY".localized;
		self.textLabel?.font = UIFont.systemFontOfSize(17);
		self.textLabel?.textColor = UIColor.whiteColor();
		self.addSubview(self.textLabel);
	}
	
}

class EmptyListCell : UITableViewCell{
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder);
	}
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier);
		self.textLabel?.textAlignment = .Center;
		self.textLabel?.text = "_LIST_EMPTY".localized;
		self.textLabel?.font = UIFont.systemFontOfSize(17);
		self.textLabel?.textColor = UIColor.whiteColor();
	}
}
