//
//  UserInfoView.swift
//  Flirtbox
//
//  Created by sergey petrachkov on 05/07/16.
//  Copyright © 2016 flirtbox. All rights reserved.
//

import Foundation

enum eUserInfo {
	case Sexuality
	case Age
	case Town
	case Country
	case OriginalCountry
	case Profession
	case Height
	case Bodyshape
	case Hairstyle
	case Eyecolor
	case Education
}

protocol UserInfoDelegate{
	func onUserInfoChangeRequested(type: eUserInfo);
}

class UserInfoView: UIView {
	var imageView: UIImageView!
	var textLabel: UILabel!
	var editButton: UIButton!
	var separatorView: UIView!
	var type : eUserInfo!
	var delegate : UserInfoDelegate?
	
	override func awakeFromNib() {
		super.awakeFromNib();
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder);
		
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame);
		
		imageView = UIImageView(frame: CGRectMake(10, frame.height / 2 - 6, 16, 12));
		self.addSubview(imageView);
		
		textLabel = UILabel();
		textLabel.textColor = UIColor.lightGrayColor();
		textLabel.text = "AGE|COUNTRY|SEXUALITY";
		textLabel.font = UIFont(name: "Roboto-Regular", size: 14);
		self.addSubview(textLabel);
		
		editButton = UIButton();
		editButton.setTitle("_EDIT".localized, forState: .Normal);
		editButton.setTitleColor(UIColor(red: 28.0/255, green: 187.0/255, blue: 240.0/255, alpha: 1), forState: .Normal);
		editButton.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted);
		if let title = editButton.titleLabel{
			title.font = UIFont(name: "Roboto-Regular", size: 14);
			title.textAlignment = .Right
		}
		self.addSubview(editButton);
		
		separatorView = UIView(frame: CGRectMake(0, frame.height - 1, frame.width, 1));
		separatorView.backgroundColor = UIColor(red: 243.0/255, green: 243.0/255, blue: 243.0/255, alpha: 1);
		self.addSubview(separatorView);
		self.editButton.addTarget(self, action: #selector(UserInfoView.editButtonTapped(_:)), forControlEvents: .TouchUpInside);
	}
	
	convenience init (imagename: String, text: String, frame: CGRect, type: eUserInfo, delegate: UserInfoDelegate? = nil){
		self.init(frame: frame);
		self.type = type;
		self.imageView.image = UIImage(named: imagename);
		self.textLabel.text = text;
		self.textLabel.sizeToFit();
		self.delegate = delegate;
	}
	
	func configureWith(imageName: String, text: String, buttonText: String?, hideSeparator: Bool = false){
		self.imageView.image = UIImage(named: imageName);
		self.textLabel.text = text;
		self.textLabel.sizeToFit();
		self.separatorView.hidden = hideSeparator;
		if(buttonText != nil){
			self.editButton.setTitle(buttonText, forState: .Normal);
		}
		self.editButton.sizeToFit();
		
	}
	
	func configureWithValue(text: String){
		self.editButton.setTitle(text, forState: .Normal);
	}
	
	override func layoutSubviews() {
		self.textLabel.frame = CGRectMake(self.imageView.frame.maxX + 10, self.frame.height / 2 - self.textLabel.frame.height / 2, 175, self.textLabel.frame.height);
		self.editButton.frame = CGRectMake(self.frame.width - max(self.editButton.frame.width,46) - 10,
		                                   0,
		                                   max(self.editButton.frame.width,46),
		                                   self.frame.height);
	}
	func editButtonTapped (sender: UIButton){
		self.delegate?.onUserInfoChangeRequested(self.type);
	}

}
