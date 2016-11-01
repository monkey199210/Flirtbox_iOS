//
//  UIFont+.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 09.12.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    func sizeOfString (string: NSString, constrainedToWidth width: Double) -> CGSize {
        return string.boundingRectWithSize(CGSize(width: width, height: DBL_MAX),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName: self],
            context: nil).size
    }
    func sizeOfString (string: NSString, constrainedToWidth width: Double, constrainedToHeight height: Double) -> CGSize {
        return string.boundingRectWithSize(CGSize(width: width, height: height),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName: self],
            context: nil).size
    }
}