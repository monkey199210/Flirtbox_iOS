//
//  MenuCell.swift
//  Flirtbox
//
//  Created by sergey petrachkov on 23/06/16.
//  Copyright © 2016 flirtbox. All rights reserved.
//

import Foundation
class MenuItem{
	var title: String!;
	var pictureName : String!;
	var tag: Int!;
	convenience init(title: String, pictureName: String, tag: Int){
		self.init();
		self.title = title;
		self.pictureName = pictureName;
		self.tag = tag;
	}
	
	static let OnlineItem : MenuItem = MenuItem(title: "_ONLINE".localized, pictureName: "menuOnline", tag : 0);
	static let RadarItem : MenuItem = MenuItem(title: "_RADAR".localized, pictureName: "menuRadar", tag: 1);
	static let SearchItem : MenuItem = MenuItem(title: "_SEARCH".localized, pictureName: "menuSearch", tag: 2);
	static let SexyItem : MenuItem = MenuItem(title: "_SEXYORNOT".localized, pictureName: "menuSexy", tag: 3);
	static let ProfileItem : MenuItem = MenuItem(title: "_PROFILE".localized, pictureName: "menuProfile", tag: 4);
	static let MessagesItem : MenuItem = MenuItem(title: "_MESSAGES".localized, pictureName: "menuMessages", tag: 5);
	static let MeetingsItem : MenuItem = MenuItem(title: "_MEETINGS".localized, pictureName: "menuMeetings", tag: 6);
	static let VisitorsItem : MenuItem = MenuItem(title: "_VISITORS".localized, pictureName: "menuVisitors", tag: 7);
	static let FavsItem : MenuItem = MenuItem(title: "_FAVOURITES".localized, pictureName: "menuFave", tag: 8);
	static let BlockedItem : MenuItem = MenuItem(title: "_BLOCKED".localized, pictureName: "menuBlocked", tag: 9);
	static let PremiumItem : MenuItem = MenuItem(title: "_PREMIUM".localized, pictureName: "menuPremium", tag: 10);
	static let SettingsItem : MenuItem = MenuItem(title: "_SETTINGS".localized, pictureName: "menuSettings", tag: 11);
	static let FeedbackItem : MenuItem = MenuItem(title: "_FEEDBACK".localized, pictureName: "menuFeedback", tag: 12);
	static let AboutItem : MenuItem = MenuItem(title: "_ABOUT_US".localized, pictureName: "menuAbout", tag: 13);
	static let LogoutItem : MenuItem = MenuItem(title: "_LOGOUT".localized, pictureName: "menuLogout", tag: 14);

}
class MenuCell: UITableViewCell{
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier);
		self.textLabel?.font = UIFont.systemFontOfSize(15);
		self.backgroundColor = UIColor.clearColor();
		self.textLabel?.textColor = UIColor.whiteColor();
		self.separatorInset = UIEdgeInsetsZero;
		self.selectionStyle = .Blue;
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configureWithTitle(title: String, imageName: String, tag: Int){
		self.textLabel?.text = title;
		self.imageView?.image = UIImage(named: imageName);
		self.tag = tag;
	}
}