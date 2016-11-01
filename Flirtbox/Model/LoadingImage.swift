//
//  LoadingImage.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 07.12.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit
import Haneke
import ImageIO

class LoadingImage: UIImage {
    override init() {
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    required convenience init(imageLiteral name: String) {
        fatalError("init(imageLiteral:) has not been implemented")
    }
    
    override init?(data: NSData) {
        super.init(data: data)
    }
    
    init(image: UIImage, key: String){
        super.init(data:UIImageJPEGRepresentation(image,1.0)!)!
        self.key = key
    }
    
    var loadingChecker: [((Double) -> Void)] = []
    var loadProgress: Double = 1.0 {
        didSet {
            for checker in loadingChecker {
                checker(loadProgress)
            }
        }
    }
    private var key: String!
    
    static let kNeedToLoadImageKeys = "kNeedToLoadImageKeys"
    class func createImage(image: UIImage) -> (image: LoadingImage, order: String) {
        let imageKeys = LoadingImage.getImageKeys()
        let newKeys = NSMutableArray(array: imageKeys)
        let order = Int(NSDate().timeIntervalSince1970)
        let key = String(order)
        needToLoadImageCache.set(value: image, key: key)
        newKeys.addObject(key)
        saveImageKeys(newKeys)
        let loadingImage = LoadingImage(image: image, key:key)
        loadingImage.checkLoading()
        return (loadingImage, key)
    }
    class func images(completition: ((image: LoadingImage, order: String)) -> Void){
        for key in getImageKeys() as! [String] {
            needToLoadImageCache.fetch(key: key).onSuccess({ (image) -> () in
                let loadingImage = LoadingImage(image: image, key:key)
                loadingImage.checkLoading()
                completition((loadingImage, key))
            })
        }
    }
    class func removeNeedToLoadImages() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.removeObjectForKey(LoadingImage.kNeedToLoadImageKeys)
        userDefaults.synchronize()
        needToLoadImageCache.removeAll()
    }
    private class func getImageKeys() -> NSArray {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let imageKeys = userDefaults.objectForKey(LoadingImage.kNeedToLoadImageKeys) as? NSArray {
            return imageKeys
        }else{
            let array = NSArray(array: [])
            userDefaults.setObject(array, forKey: LoadingImage.kNeedToLoadImageKeys)
            userDefaults.synchronize()
            return array
        }
    }
    private class func saveImageKeys(array: NSArray) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(array, forKey: kNeedToLoadImageKeys)
        userDefaults.synchronize()
    }
    private func checkLoading() {
        let imageKeys = LoadingImage.getImageKeys()
        if imageKeys.containsObject(self.key) {
            Net.uploadImage(self) { (progress) -> Void in
                self.loadProgress = progress
                print(self.loadProgress)
                }.onSuccess(callback: { (_) -> Void in
                    let newKeys = NSMutableArray(array: LoadingImage.getImageKeys())
                    newKeys.removeObject(self.key)
                    LoadingImage.saveImageKeys(newKeys)
                    LoadingImage.needToLoadImageCache.remove(key: self.key)
                    self.loadProgress = 1.0
                    GoogleAnalitics.send(GoogleAnalitics.MainScreen.Category, action: GoogleAnalitics.MainScreen.UPLOAD_SUCCESS)
                }).onFailure(callback: { (_) -> Void in
                    self.loadProgress = 1.0
                    GoogleAnalitics.send(GoogleAnalitics.MainScreen.Category, action: GoogleAnalitics.MainScreen.UPLOAD_ERROR)
                })
        }
    }
    private static let needToLoadImageCache = Cache<UIImage>(name: LoadingImage.kNeedToLoadImageKeys)
}
