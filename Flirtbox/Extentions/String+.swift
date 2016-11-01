//
//  String+.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 21.11.15.
//  Edited by Sergey Petrachkov on 09.06.16
//  Copyright © 2015 flirtbox. All rights reserved.
//

import Foundation
extension String {
	var localized : String {
		return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "")
	}
	
    var length : Int {
        return self.characters.count
    }
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluateWithObject(self)
        return result
    }
    func isValidUserName() -> Bool {
        let userNameRegEx = "[A-Z0-9a-z_-]{5,16}"
        let userNameTest = NSPredicate(format:"SELF MATCHES %@", userNameRegEx)
        let result = userNameTest.evaluateWithObject(self)
        return result
    }
	
	static func getFormattedDate(dateToFormatStr : String, format : String = "yyyy-MM-dd HH:mm") -> String{
		var date = NSDate(fromString: dateToFormatStr, format: .Custom(format))
		date = date.dateByAddingSeconds(NSTimeZone.localTimeZone().secondsFromGMT)
		if NSDate().secondsAfterDate(date) < 0 {
			date = date.dateBySubtractingHours(1)
		}
		if date.isToday() {
			return date.toString(format: .Custom("HH:mm"))
		}else{
			return date.toString(format: .Custom("dd.MM.yyyy"))
		}
	}
	
	static func getChatTimeString(time: String) -> String {
		var timeString = " "
		var date = NSDate(fromString: time, format: .Custom("yyyy-MM-dd HH:mm"))
		date = date.dateByAddingSeconds(NSTimeZone.localTimeZone().secondsFromGMT)
		if NSDate().secondsAfterDate(date) < 0 {
			date = date.dateBySubtractingHours(1)
		}
		if date.isToday() {
			let seconds = NSDate().secondsAfterDate(date)
			if seconds > 0 {
				if seconds > 60 * 60 {
					timeString = "\(Int(seconds/(60 * 60))) hours ago"
				}else if seconds > 60 {
					timeString = "\(Int(seconds/60)) min ago"
				}else{
					timeString = "\(seconds) sec ago"
				}
			}
		}else{
			timeString = date.toString(format: .Custom("dd.MM.yyyy HH:mm"))
		}
		return timeString
	}
	init(htmlEncodedString: String) {
		let encodedData = htmlEncodedString.dataUsingEncoding(NSUTF8StringEncoding)!
		let attributedOptions : [String: AnyObject] = [
			NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
			NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
		]
		do{
			let attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
			let preResultStrig = attributedString.string;
			self.init(preResultStrig.stringByReplacingOccurrencesOfString("\\n", withString: "\n").stringByReplacingOccurrencesOfString("\\", withString: ""));
		}
		catch
		{
			self.init("");
		}
	}
}