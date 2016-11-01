//
//  UserProfile.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 04.12.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import Foundation
import AlamofireImage
import Crashlytics
import BrightFutures
import Haneke

class UserProfile {
    static let userProfile = UserProfile()
    init(){
        self.needToLoadImage = self.readNeedToLoadImage()
        FBEvent.onAuthenticated().listen(self) { [unowned self] (isAuthenticated) -> Void in
            if isAuthenticated {
                //auth done
                if let profileImage = self.needToLoadImage {
                    Net.uploadImage(profileImage).onSuccess(callback: { (_) -> Void in
                        FBEvent.pictChanged(true)
                        self.removeNeedToLoadImage()
                    })
                }
                Net.me().onSuccess(callback: { (user) -> Void in
                    UserProfile.userProfile.user = user
                    FBEvent.profileReceived(user)
                    if let email = user.general.email.email {
                        Crashlytics.sharedInstance().setUserEmail(email)
                    }
                    Crashlytics.sharedInstance().setUserIdentifier(user.general.username)
                    Crashlytics.sharedInstance().setUserName(user.general.username)
                })
            }else{
                //logout done
                UserProfile.clearCachedItems()
            }
        }
        FBEvent.onProfileUpdated().listen(self) { (_) -> Void in
            Net.me().onSuccess(callback: { (user) -> Void in
                UserProfile.userProfile.user = user
                FBEvent.profileReceived(user)
            })
        }
    }
    
    private static let kIsUserHavePhotoKey = "kIsUserHavePhotoKey"
    class func isIHavePhoto() -> Bool {
        let userdefaults = NSUserDefaults.standardUserDefaults()
        return userdefaults.boolForKey(kIsUserHavePhotoKey)
    }
    private class func setHavePhoto(isHave: Bool) {
        let userdefaults = NSUserDefaults.standardUserDefaults()
        if userdefaults.boolForKey(kIsUserHavePhotoKey) != isHave {
            userdefaults.setBool(isHave, forKey: kIsUserHavePhotoKey)
            userdefaults.synchronize()
        }
    }
    var user: FBUser?
    class func clearCachedItems() {
        UserProfile.userProfile.removeNeedToLoadImage()
        UserProfile.clearMainPictUrl()
        UserProfile.userProfile.user = nil
        UserProfile.circledMainImage = nil
    }
    private static var isMeRequesting = false
    class func currentUser() -> FBUser? {
        if UserProfile.userProfile.user == nil {
            if !isMeRequesting {
                isMeRequesting = true
                Net.me().onSuccess(callback: { (user) -> Void in
                    UserProfile.userProfile.user = user
                    FBEvent.profileReceived(user)
                    isMeRequesting = false
                }).onFailure(callback: { (error) -> Void in
                    isMeRequesting = false
                })
            }
        }
        return UserProfile.userProfile.user
    }
    class func removeNeedToLoadImage() {
        UserProfile.userProfile.removeNeedToLoadImage()
    }
    private func removeNeedToLoadImage() {
        self.needToLoadImage = nil
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let destinationPath = documentsPath + UserProfile.kMainProfileFile
        if NSFileManager.defaultManager().fileExistsAtPath(destinationPath) {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(destinationPath)
            }
            catch let error as NSError {
                print(error)
            }
        }
    }
    private func readNeedToLoadImage() -> UIImage? {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let destinationPath = documentsPath + UserProfile.kMainProfileFile
        if NSFileManager.defaultManager().fileExistsAtPath(destinationPath) {
            let image = UIImage(contentsOfFile: destinationPath)
            return image
        }else{
            return nil
        }
    }
    private var needToLoadImage: UIImage?
    static let kMainProfileFile = "/needToLoadImage.jpg"
    class func setNeedToLoadImage(image: UIImage) {
        userProfile.needToLoadImage = image
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let destinationPath = documentsPath + kMainProfileFile
        if let imageData = UIImageJPEGRepresentation(image,1.0) {
            imageData.writeToFile(destinationPath, atomically: true)
        }
    }
    class func circledNeedToLoadImage() -> UIImage? {
        if let profileImage = userProfile.needToLoadImage {
            let circularImage = profileImage.af_imageRoundedIntoCircle()
            return circularImage
        }else{
            return nil
        }
    }
    private static let kProfileImagesCache = "profileImagesCache"
    private static let kMainImageUrl = "kMainImageUrl"
    class private func saveMainPictureUrl(url: String) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(url, forKey: kMainImageUrl)
        userDefaults.synchronize()
        FBEvent.mainPickSaved(true)
    }
    class func mainPictUrl() -> String? {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        return userDefaults.objectForKey(kMainImageUrl) as! String?
    }
    class func clearMainPictUrl() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.removeObjectForKey(kMainImageUrl)
        userDefaults.synchronize()
        FBEvent.mainPickSaved(true)
    }
    private static var circledMainImage: UIImage?
    class func getCircledMainImage(completition: (UIImage) -> Void) {
        if let circledMainImage = self.circledMainImage {
            completition(circledMainImage)
        }else{
            self.getMainPict { (image) -> Void in
                if image == nil {
                    completition(self.getEmptyImage().af_imageRoundedIntoCircle())
                }else{
                    circledMainImage = image!.af_imageRoundedIntoCircle()
                    completition(circledMainImage!)
                }
            }
        }
    }
    class func getEmptyImage() -> UIImage {
        return UIImage(named: R.AssetsAssets.empty.takeUnretainedValue() as String)!
    }
    private static let imageCache = Cache<UIImage>(name: kProfileImagesCache)
    class func getMainPict(completition: (UIImage?) -> Void) {
        if let mainUrl = self.mainPictUrl() {
            if let URL = NSURL(string: mainUrl) {
                imageCache.fetch(URL: URL).onSuccess { img in
                    completition(img)
                }
            }else{
                completition(nil)
            }
        }else{
            completition(nil)
        }
    }
    class func images(completition: ((image:UIImage,order:String)) -> Void) -> Future<[FBPicture], NSError> {
        let promise = Promise<[FBPicture], NSError>()
        Net.pictureList().onSuccess { (pictures) -> Void in
            let sortedPictures = pictures.sort({ (first, second) -> Bool in
                return Int(first.orderid) > Int(second.orderid)
            })
            for picture in sortedPictures {
                if picture.mainpic == "1" {
                    self.saveMainPictureUrl(picture.getUrl())
                }
                if let URL = NSURL(string: picture.getUrl()) {
                    imageCache.fetch(URL: URL).onSuccess { image in
                        completition((image, picture.orderid))
                    }
                }
            }
            if sortedPictures.count > 0 {
                UserProfile.setHavePhoto(true)
            }else{
                UserProfile.setHavePhoto(false)
            }
            promise.success(sortedPictures)
        }.onFailure { (error) -> Void in
            promise.failure(error)
        }
        return promise.future
    }
    class func uploadImage(image: UIImage) -> (image: LoadingImage, order: String) {
        return LoadingImage.createImage(image)
    }
    class func isPushTokenPresent(refreshToken: String) -> Bool
    {
        if let userP = UserProfile.userProfile.user
        {
            if let registrationId = userP.general.registrationIds
            {
                if registrationId.contains(refreshToken)
                {
                    return true
                }
            }
        }
        return false
    }
}