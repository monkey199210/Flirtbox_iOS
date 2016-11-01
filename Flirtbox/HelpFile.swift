//
//  HelpFile.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 05.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import Foundation
import UIKit
import CoreTelephony

struct FBoxConstants {
    
    static let IS_RETINA = (UIScreen.mainScreen().scale >= 2.0)
    static let IS_IPHONE = (UIDevice.currentDevice().userInterfaceIdiom == .Phone)
    static let IS_IPAD = (UIDevice.currentDevice().userInterfaceIdiom == .Pad)
    
    static let SCREEN_WIDTH = (UIScreen.mainScreen().bounds.size.width)
    static let SCREEN_HEIGHT = (UIScreen.mainScreen().bounds.size.height)
    static let SCREEN_MAX_LENGTH = max(SCREEN_WIDTH, SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH = min(SCREEN_WIDTH, SCREEN_HEIGHT)
    
    static let IS_IPHONE_4_OR_LESS = (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
    static let IS_IPHONE_5 = (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
    static let IS_IPHONE_6 = (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
    static let IS_IPHONE_6P = (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
    
    static func SYSTEM_VERSION_EQUAL_TO(version: String) -> Bool{
        return UIDevice.currentDevice().systemVersion.compare(version, options: NSStringCompareOptions.NumericSearch) == NSComparisonResult.OrderedSame
    }
    
    static func SYSTEM_VERSION_GREATER_THAN(version: String) -> Bool{
        return UIDevice.currentDevice().systemVersion.compare(version, options: NSStringCompareOptions.NumericSearch) == NSComparisonResult.OrderedDescending
    }
    
    static func SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version: String) -> Bool{
        return UIDevice.currentDevice().systemVersion.compare(version, options: NSStringCompareOptions.NumericSearch) != NSComparisonResult.OrderedAscending
    }
    
    static func SYSTEM_VERSION_LESS_THAN(version: String) -> Bool{
        return UIDevice.currentDevice().systemVersion.compare(version, options: NSStringCompareOptions.NumericSearch) == NSComparisonResult.OrderedAscending
    }
    
    static func SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(version: String) -> Bool{
        return UIDevice.currentDevice().systemVersion.compare(version, options: NSStringCompareOptions.NumericSearch) != NSComparisonResult.OrderedDescending
    }
    
    
    ///////////////------------////////////////
    
    
    struct NotificationKey {
        static let LivePostLoading = "LivePostLoading"
    }
    
    struct Path {
        static let Documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        static let Tmp = NSTemporaryDirectory()
    }
    
    struct UserDefaults {
        static let IgnoreFollowingCache = "kIgnoreFollowingCache"
    }
    
    static let kAnimationDuration: NSTimeInterval = 0.5
    static let kAnimationFastDuration: NSTimeInterval = 0.3
    static let kAnimationDamping: CGFloat = 0.8
    static let kAnimationInitialVelocity: CGFloat = 0.8
    
    static let kDefaultLimit: Int = 100
}
class FBoxHelper{
    class func getSimCountryISO() -> String {
        var iso = ""
        if let firstLanguage = NSLocale.preferredLanguages().first {
            if let code = firstLanguage.componentsSeparatedByString("-").first {
                iso = code
            }
        }
        let info = CTTelephonyNetworkInfo()
        if let carrier = info.subscriberCellularProvider {
            if let code = carrier.isoCountryCode {
                iso = code
            }
        }
        return iso
    }
    class func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    class func getScreenSizeWithFix(fix: Bool) -> CGSize{
        let screenRect = UIScreen.mainScreen().bounds
        var screenWidth = screenRect.width
        var screenHeight = screenRect.height
        if(FBoxConstants.IS_RETINA && fix){
            screenWidth *= 2.0
            screenHeight *= 2.0
        }
        return CGSizeMake(screenWidth, screenHeight)
    }
    class func getScreenSize() -> CGSize{
        return getScreenSizeWithFix(true)
    }
    class func getDateFromShortString(dateString: String) -> NSDate{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyMMddHHmmss"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        return dateFormatter.dateFromString(dateString)!
    }
    class func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0);
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    private static var window: UIWindow?
    class func getWindow() -> UIWindow? {
        if window == nil {
            window = UIApplication.sharedApplication().keyWindow
        }
        return window
    }
    class func getMainController() -> MainViewController? {
        if let mainViewController = UIApplication.sharedApplication().keyWindow?.rootViewController as? MainViewController {
            return mainViewController
        }else{
            return nil
        }
    }
}