//
//  UIView+.swift
//  Quokka
//
//  Created by Azamat Valitov on 07.11.15.
//  Updated by sergey petrachkov on 2016/07/06 added helper methods
//  Copyright © 2015 Flirtbox. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    class func appearWithScale(view: UIView, duration: Double, completition: (() -> ())?) {
        view.userInteractionEnabled = false
        CATransaction.begin()
        let zoomOut0 = CABasicAnimation(keyPath: "transform.scale")
        zoomOut0.fromValue = 0.01
        zoomOut0.toValue = 2.0
        let zoomOut1 = CABasicAnimation(keyPath: "transform.scale")
        zoomOut1.toValue = 1.0
        let group = CAAnimationGroup()
        group.duration = duration
        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        group.animations = [zoomOut0, zoomOut1]
        CATransaction.setCompletionBlock { () -> Void in
            view.userInteractionEnabled = true
            if completition != nil {
                completition!()
            }
        }
        view.layer.addAnimation(group, forKey: "allMyAnimations")
        CATransaction.commit()
    }
	
	/**
	@brief It sets height of a view
 
	@discussion This method accepts a CGFloat value representing the height
 
	@param delta The value one wants the height of the view to be
	*/
	func setHeight(height: CGFloat){
		if(height == 0)
		{
			for subview in self.subviews {
				subview.frame = CGRectZero;
			}
		}
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.width, height);
	}
	
	/**
	@brief It moves view horizontally by given delta
 
	@discussion This method accepts a CGFloat value representing the delta
 
	@param delta The value one wants to move the view
	*/
	func moveHorizontallyBy (delta: CGFloat){
		self.frame = CGRectMake(self.frame.origin.x + delta, self.frame.origin.y, self.frame.width, self.frame.height);
	}
	/**
	@brief It moves view left by given delta
 
	@discussion This method accepts a CGFloat value representing the delta
 
	@param left The value one wants to move the view
	*/
	func moveLeftBy(left : CGFloat){
		self.moveHorizontallyBy(-left);
	}
	/**
	@brief It moves view right by given delta
 
	@discussion This method accepts a CGFloat value representing the delta
 
	@param right The value one wants to move the view
	*/
	func moveRightBy(right: CGFloat){
		self.moveHorizontallyBy(right);
	}
	/**
	@brief It moves view to vertically by given delta
 
	@discussion This method accepts a CGFloat value representing the delta
 
	@param delta The value one wants to move the view
	*/
	func moveVerticallyBy(delta : CGFloat){
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + delta, self.frame.width, self.frame.height);
	}
	/**
	@brief It moves view up by given delta
 
	@discussion This method accepts a CGFloat value representing the delta
 
	@param up The value one wants to move the view
	*/
	func moveUpBy(up : CGFloat){
		self.moveVerticallyBy(-up);
	}
	/**
	@brief It moves view down by given delta
 
	@discussion This method accepts a CGFloat value representing the delta
 
	@param down The value one wants to move the view
	*/
	func moveDownBy(down : CGFloat){
		self.moveVerticallyBy(down);
	}
	
	/**
	@brief It sets top (origin.y) of the vuew by given value
 
	@discussion This method accepts a CGFloat value representing the delta
 
	@param top The value one wants view to origin from vertically
	*/
	func setTop (top : CGFloat){
		self.frame = CGRectMake(self.frame.origin.x, top, self.frame.width, self.frame.height);
	}
	/**
	@brief It places view below another
 
	@discussion This method accepts a CGFloat value representing the delta
 
	@param delta anotherView.bottom + delta
	*/
	func placeDownAfter(view : UIView, delta : CGFloat){
		self.setTop(view.frame.maxY + delta);
	}
	/**
	@brief It places view to the rigt of another view
 
	@discussion This method accepts a CGFloat value representing the delta
 
	@param delta anotherView.frame.right + delta
	*/
	func placeRightAfter(view : UIView, delta : CGFloat){
		self.moveRightBy(view.frame.maxX + delta);
	}
}