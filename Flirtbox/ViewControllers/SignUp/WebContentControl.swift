//
//  WebContentControl.swift
//  Flirtbox
//
//  Created by sergey petrachkov on 29/06/16.
//  Copyright © 2016 flirtbox. All rights reserved.
//

import Foundation
protocol WebContentControlDelegate{
	func closeDialog();
}
class WebContentControl : UIView, UIWebViewDelegate {
	
	@IBOutlet weak var webView: UIWebView!
	@IBOutlet weak var titleLabel: UILabel!
	var delegate : WebContentControlDelegate?
	override func awakeFromNib() {
		super.awakeFromNib();
	}
	
	func setupAs(typeOf: eSignUpDisclaimerNavigationParam){
		var htmlString : String? = "";
		switch typeOf {
		case .PrivacyPolicy:
			self.titleLabel.text = "_PRIVACY_POLICY".localized
			htmlString = try! NSString(contentsOfFile: NSBundle.mainBundle().pathForResource("policy", ofType: "html")!, encoding: NSUTF8StringEncoding) as String;
			break;
		case .TermsAndConditions:
			self.titleLabel.text = "_TERMS_AND_CONDITIONS_TITLE".localized
			htmlString = try! NSString(contentsOfFile: NSBundle.mainBundle().pathForResource("terms", ofType: "html")!, encoding: NSUTF8StringEncoding) as String;
			break;
		}
		self.webView.loadHTMLString(htmlString!, baseURL: NSBundle.mainBundle().bundleURL);
	}
	@IBAction func okAction(sender: AnyObject) {
		self.delegate?.closeDialog();
	}
	override func layoutSubviews() {
		super.layoutSubviews();
//		let shadowPath = UIBezierPath(rect: self.bounds);
//		self.clipsToBounds = true;
//		self.layer.cornerRadius = 2;
//		self.layer.borderColor = UIColor.blackColor().CGColor;
//		self.layer.borderWidth = 0.5;
//		self.layer.shadowColor = UIColor.blackColor().CGColor;
//		self.layer.shadowOffset = CGSizeMake(0.0, 0.5);
//		self.layer.shadowOpacity = 0.5;
//		self.layer.shadowPath = shadowPath.CGPath;
	}
}
