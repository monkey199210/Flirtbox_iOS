//
//  AboutMeViewController+HideFields.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 29.01.16.
//  Copyright © 2016 flirtbox. All rights reserved.
//

import Foundation
import UIKit

extension AboutMeViewController {
    func hideAgeField() {
		self.ageView.setHeight(0);
		self.ageView.hidden = true;
//		whiteViewHeightConstraint.constant = self.getCalculatedHeight();
		whiteViewHeightConstraint.constant -= 60;
        self.view.layoutSubviews();
    }
    func hideTownField() {
		self.townView.setHeight(0);
		self.townView.hidden = true;
		//		whiteViewHeightConstraint.constant = self.getCalculatedHeight();
		whiteViewHeightConstraint.constant -= 60;
        self.view.layoutSubviews();
    }
    func hideCountryField() {
		self.countryView.setHeight(0);
		self.countryView.hidden = true;
		//		whiteViewHeightConstraint.constant = self.getCalculatedHeight();
		whiteViewHeightConstraint.constant -= 60;
        self.view.layoutSubviews();
    }
    func hideOriginalCountryField() {
		self.originalCountryView.setHeight(0);
		self.originalCountryView.hidden = true;
		//		whiteViewHeightConstraint.constant = self.getCalculatedHeight();
		whiteViewHeightConstraint.constant -= 60;
        self.view.layoutSubviews();
    }
    func hideHeightField() {
		self.heightView.setHeight(0);
		self.heightView.hidden = true;
		//		whiteViewHeightConstraint.constant = self.getCalculatedHeight();
		whiteViewHeightConstraint.constant -= 60;
        self.view.layoutSubviews();
    }
    func hideBodyshapeField() {
		self.bodyshapeView.setHeight(0);
		self.bodyshapeView.hidden = true;
		//		whiteViewHeightConstraint.constant = self.getCalculatedHeight();
		whiteViewHeightConstraint.constant -= 60;
        self.view.layoutSubviews();
    }
    func hideHairStyleField() {
		self.hairstyleView.setHeight(0);
		self.hairstyleView.hidden = true;
		//		whiteViewHeightConstraint.constant = self.getCalculatedHeight();
		whiteViewHeightConstraint.constant -= 60;
        self.view.layoutSubviews();
    }
    func hideEyeColourField() {
		self.eyecolorView.setHeight(0);
		self.eyecolorView.hidden = true;
		//		whiteViewHeightConstraint.constant = self.getCalculatedHeight();
		whiteViewHeightConstraint.constant -= 60;
        self.view.layoutSubviews();
    }
    func hideEducationField() {
		self.educationView.setHeight(0);
		self.educationView.hidden = true;
		//		whiteViewHeightConstraint.constant = self.getCalculatedHeight();
		whiteViewHeightConstraint.constant -= 60;
        self.view.layoutSubviews();
    }
    func hideProfessionField() {
		self.professionView.setHeight(0);
		self.professionView.hidden = true;
		//		whiteViewHeightConstraint.constant = self.getCalculatedHeight();
		whiteViewHeightConstraint.constant -= 60;
        self.view.layoutSubviews();
    }
    func hideSexualityField() {
		self.sexualityView.setHeight(0);
		self.sexualityView.hidden = true;
		//		whiteViewHeightConstraint.constant = self.getCalculatedHeight();
		whiteViewHeightConstraint.constant -= 60;
		self.view.layoutSubviews();
    }
	
	func getCalculatedHeight()->CGFloat{
		var result : CGFloat = 0;
		for subview in self.whiteView.subviews {
			result += subview.frame.height;
		}
		return result;
	}
}