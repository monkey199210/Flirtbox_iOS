//
//  Net+.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 08.12.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import Foundation

extension Net {
    enum SingleProfileItems: String {
        case DESCRIPTION = "DESCRIPTION"
        case HEIGHT = "HEIGHT"
        case BODYSHAPE = "BODYSHAPE"
        case HAIRCOLOUR = "HAIRCOLOUR"
        case EYECOLOUR = "EYECOLOUR"
        case EDUCATION = "EDUCATION"
        case SEXUALITY = "SEXUALITY"
        case HAIRSTYLE = "HAIRSTYLE"
        case PROFESSION = "PROFESSION"
        case AGE = "AGE"
        case TOWN = "TOWN"
        case COUNTRY = "COUNTRY"
        case ORIGINALCOUNTRY = "ORIGINALCOUNTRY"
    }
    enum TagProfileItems: String {
        case LOOKINGFOR = "LOOKINGFOR"
        case LANGUAGES = "LANGUAGES"
        case QUESTIONS = "QUESTIONS"
    }
    enum SettingItems: Int {
        case _EMAIL = 1
        case _PUSH = 2
    }
    enum UserSettings: String {
        case pref_shareprofile = "1"
        case pref_profile_searchable = "2"
        case pref_location_update = "3"
        case pref_push_notifications = "4"
        case pref_email_notifications = "5"
    }
    enum UserNotifications: String {
        case _NEW_MESSAGE = "1"
        case _MESSAGE_REPLY = "2"
        case _MESSAGE_FROM_FAVOURITE_USER = "3"
        case _PICTURE_APPROVED = "4"
        case _PICTURE_DISAPPROVED = "5"
        case _TECHNICAL_ISSUES = "7"
        case _NEWSLETTER = "8"
        case _EMAIL = "100"
        case _PUSH = "101"
    }
    class func checkBoolField(value: AnyObject?) -> Bool {
        if let value = value {
            if (value is Bool && value as! Bool == true) || (value is String && value as! String == "true") {
                return true
            }else{
                return false
            }
        }
        return false
    }
    static let faves: [(tag: String, title: String)] = [("ACTORS", "_ACTORS".localized), ("AUTHORS", "_AUTHORS".localized), ("BANDS", "_BANDS".localized), ("GAMES", "_GAMES".localized), ("LOOKINGFOR", "_LOOKING_FOR".localized), ("MOVIES", "_MOVIES".localized), ("MUSIC", "_MUSIC".localized), ("PETS", "_PETS".localized), ("RADIO", "_RADIO".localized), ("SONGS", "_SONGS".localized), ("SPORTS", "_SPORTS".localized), ("TV", "_TV".localized), ("TVSTATION", "_TVSTATION".localized)]
}