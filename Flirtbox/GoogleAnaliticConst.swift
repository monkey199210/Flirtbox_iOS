//
//  GoogleAnaliticConst.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 05.02.16.
//  Copyright © 2016 flirtbox. All rights reserved.
//

import Foundation

struct GoogleAnalitics {
    static let kAdUnitID = "ca-app-pub-3940256099942544/2934735716"
    static let kBannerHeight: CGFloat = 50.0
    static func send(category: String, action: String, label: String? = nil, value: NSNumber? = nil) {
        let tracker = GAI.sharedInstance().defaultTracker
        let dict = GAIDictionaryBuilder.createEventWithCategory(category, action: action, label: label, value: value).build()
        tracker.send(dict as [NSObject : AnyObject])
    }
    struct Api {
        static let Category = "Api"
        static let TIMEOUT_FIRST = "Timeout.1st"
        static let TIMEOUT_SECOND = "Timeout.2nd"
        static let TIMEOUT_THIRD = "Timeout.3rd"
        static let ERROR_GENERAL = "Unexpected"
        static let SLOW = "Slow"
        static let RESPONSE_BACKGROUND = "Response in background"
        static let EMPTY_JSON = "Empty response"
        static let NORMAL = "Normal"
        static let INVALID_JSON = "Invalid JSON"
    }
    struct AuthenticatorSplashScreen {
        static let Category = "Authenticator splash screen"
        static let LOGIN_FB_SUCCESS = "Login facebook success"
        static let LOGIN_FB_ERROR = "Login facebook error"
        static let FB_SDK_ERROR = "Facebook SDK error"
    }
    struct Login {
        static let Category = "Login"
        static let LOGIN = "Normal login"
        static let LOGIN_ERROR = "Normal login error"
        static let LOGIN_FB = "Facebook login"
        static let LOGIN_FB_ERROR = "Facebook login error"
        static let FB_SDK_ERROR = "Facebook SDK error"
    }
    struct Signup {
        static let Category = "Signup"
        static let SIGNUP_SUCCESS = "Signup success"
        static let SIGNUP_ERROR = "Signup error"
        static let SIGNUP_FB_SUCCESS = "Signup facebook success"
        static let SIGNUP_FB_ERROR = "Signup facebook error"
        static let SIGNUP_UPLOAD_SUCCESS = "Upload picture success"
        static let SIGNUP_UPLOAD_ERROR = "Upload picture error"
    }
    struct MainScreen {
        static let Category = "Main screen"
        static let LOGOUT = "Logout"
        static let UPLOAD_SUCCESS = "Upload picture success"
        static let UPLOAD_ERROR = "Upload picture error"
    }
    struct OthersProfile {
        static let Category = "Others' Profile"
        static let VIEW = "Profile view"
        static let YES = "Yes"
        static let NO = "No"
        static let REPORT = "Report"
        static let BLOCK = "Block"
        static let UNBLOCK = "Unblock"
        static let CONVERSATION = "Open conversation"
        static let NOT_CONTACTABLE = "Not contactable"
        static let NOT_VISIBLE = "Not visible"
        static let FAVORITE = "Add favorite"
        static let REMOVE_FAVORITE = "Remove favorite"
        static let NULL_PROFILE = "Null profile"
    }
    struct OtherProfilesFavorites {
        static let Category = "Other's Favorites"
        static let ADD = "Add favorite"
    }
    struct Profile {
        static let Category = "Profile"
        static let UPLOAD_SUCCESS = "Upload picture success"
        static let UPLOAD_ERROR = "Upload picture error"
        static let ORDER_PICTURES = "Order pictures"
    }
    struct OwnAbout {
        static let Category = "Own About"
        static let UPDATE = "Update"
        static let ADD = "Add"
    }
    struct OwnFavorites {
        static let Category = "Own Favorites"
        static let ADD = "Add favorite"
        static let UPDATE = "Update favorite"
        static let REMOVE = "Delete favorite"
    }
    struct OwnQuestions {
        static let Category = "Own Questions"
        static let ANSWER = "Answer"
        static let EMPTY = "Empty"
    }
    struct MessageBox {
        static let Category = "Message box"
        static let ARCHIVE = "Archive conversation"
        static let DELETE = "Delete conversation"
    }
    struct Conversation {
        static let Category = "Conversation"
        static let READ_MESSAGES = "Read messages"
        static let SEND_MESSAGE = "Send message"
        static let DELETE_CONVERSATION = "Delete"
        static let ARCHIVE_CONVERSATION = "Archive"
    }
    struct SexyOrNot {
        static let Category = "Sexy or Not"
        static let VOTE = "Vote"
    }
    struct Online {
        static let Category = "Online"
        static let FILTER = "Filter last active"
    }
}

