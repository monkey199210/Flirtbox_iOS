//
//  Webservice.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 20.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import Foundation
import Alamofire
import MRProgress
import Genome
import BrightFutures
import Async

enum Gender: String {
    case Male = "m"
    case Female = "f"
}
enum Sexuality: Int {
    case Msf = 1, Msmf, Msm, Fsm, Fsmf, Fsf
}
enum Visibility: Int {
    case Any = 1, MembersOnly, MembersWithPhoto
    static func fromString(string: String) -> Visibility {
        var v: Visibility = .Any
        switch string {
        case "1":
            v = .Any
        case "2":
            v = .MembersOnly
        case "3":
            v = .MembersWithPhoto
        default:
            break
        }
        return v
    }
}
enum UserAction: String {
    case AddFavourite = "addFavourite"
    case RemoveFavourite = "removeFavourite"
    case Block = "block"
    case Unblock = "unblock"
    case WantToMeet = "wantToMeet"
    case RemoveWantToMeet = "removeWantToMeet"
}
enum ReportType: Int {
    case OffensivePicture = 1, StolenOrFakePicture, AdvertisingOrCommercialInterests, Scammer, NastyRudeBehaviour, InconsistentProfile, Other
}
enum SortField: String {
    case Sent = "sent"
    case Received = "received"
    case AverageVote = "averageVote"
    case Approvedwhen = "approvedwhen"
    case Uploadwhen = "uploadwhen"
    case RegdateTime = "regdateTime"
    case Lastactive = "lastactive"
}
enum NotificationsName: String {
    case NewMessage = "_NEW_MESSAGE"
    case MessageReply = "_MESSAGE_REPLY"
    case MessageFromFaveUser = "_MESSAGE_FROM_FAVOURITE_USER"
    case PictureApproved = "_PICTURE_APPROVED"
    case PictureDisapproved = "_PICTURE_DISAPPROVED"
    case TechnicalIssue = "_TECHNICAL_ISSUES"
    case Newsletter = "_NEWSLETTER"
}
enum SettingsName: String {
    case PrefShareprofile = "pref_shareprofile"
    case PrefProfileSearchable = "pref_profile_searchable"
    case PrefLocationUpdate = "pref_location_update"
    case PrefPushNotifications = "pref_push_notifications"
    case PrefEmailNotifications = "pref_email_notifications"
}
extension NSURL {
    class func FBURL(urlString: String) -> NSURL? {
		let url = NSURL(string: String.FBURL(urlString));
        return url
    }
}
//es de com
extension String {
    static func FBURL(urlString: String) -> String {
		let localeCode = getLocaleCode();
		var urlDomain = "com";
		if(localeCode == "de" || localeCode == "es"){
			urlDomain = localeCode;
		}
		let url = (NSString(format: FBNet.API_BASE_URL, urlDomain) as String)  + urlString;
		return url;
    }
	static func getLocaleCode()->String{
		let locale = NSLocale.preferredLanguages()[0] as String;
		return locale.substringToIndex(locale.startIndex.advancedBy(2));
	}
}

struct FBNet {
    
    static let UserAgent = "flirtboxApp/iOS"
    
    static let TERMS = "https://www.flirtbox.com/terms.php"
    static let PROFILE_PIC_HIGH_RES = "https://www.flirtbox.com/images/userpics/profile1023/"
    static let PROFILE_PIC_LOW_RES = "https://www.flirtbox.com/images/userpics/profile480/"
    static let PROFILE_PIC_SMALL = "https://www.flirtbox.com/images/userpics/small/"
    static let PROFILE_DEFAULT_PIC = "https://www.flirtbox.com/images/no-photo-62x62.jpg"
    static let API_BASE_URL = "https://www.flirtbox.%@/"
    static let USER_SIGNUP = "api/v1/user/save"
    static let FACEBOOK_SIGNUP = "api/fbSignupApi.php"
    static let FACEBOOK_LOGIN = "api/fbLoginApi.php"
    static let USER_DATA = "api/v1/user"
    static let ME = "api/v1/user/me"
	
    static let CLIENT_ID_PARAM = "client_id"
    static let CLIENT_ID = "testclient"
    static let LOCATION_PARAM = "term"
    static let EMAIL_PARAM = "email"
    static let CHECK_PARAM_TYPE = "type"
    static let CHECK_PARAM_EMAIL = "email"
    static let CHECK_PARAM_USERNAME = "username"
    static let COUNTRYCODE_PARAM = "countryCode"
    static let CLIENT_SECRET_PARAM = "client_secret"
    static let CLIENT_SECRET = "testpass"
    static let GRANT_TYPE = "grant_type"
    static let GRANT_REFRESH = "refresh_token"
    static let USERPROFILE_PARAM = "username"
    static let USERNAME_PARAM = "uname"
    static let LIMIT_PARAM = "limit"
    static let SUBJECT_PARAM = "subject"
    static let OFFSET_PARAM = "offset"
    static let TOUSER_PARAM = "toUser"
    static let MESSAGE_PARAM = "message"
    static let CHECK_PARAM_CATEGORY = "categoryId"
    static let PROFILE_CATEGORY_PARAM = "categoryName"
    static let PROFILE_CATEGORY = "category"
    static let PROFILE_GENDER_PARAM = "gender"
    static let LATITUDE_PARAM = "latitude"
    static let LONGITUDE_PARAM = "longitude"
    static let SHORT_LATITUDE_PARAM = "lat"
    static let SHORT_LONGITUDE_PARAM = "lng"
    static let REGID_PARAM = "registration_id"
    static let OPERATINGSYS_PARAM = "operatingSystem"
    static let OPERATINGSYS_PARAM_VALUE = "iPhone"
    static let OPERATINGSYS_VER_PARAM = "operatingSystemVersion"
    static let DISTANCE_PARAM = "distance"
    static let SORTFIELD_PARAM = "sortField"
    static let SORTDESC_PARAM = "sortDesc"
    static let MINRATINGS_PARAM = "minRatings"
    static let MINAGE_PARAM = "minAge"
    static let MAXAGE_PARAM = "maxAge"
    static let MINSENT_PARAM = "minSent"
    static let MINRECEIVED_PARAM = "minReceived"
    static let DAYS_PARAM = "days"
    static let KEY_PARAM = "key"
    static let VALUE_PARAM = "value"
    static let PASSWORD_PARAM = "password"
    static let VISIBILITY_PARAM = "visibility"
    static let CONTACT_PARAM = "contact"
    static let CODE_PARAM = "code"
    static let PHONE_PARAM = "phone"
    static let PICID_PARAM = "picid"
    static let VOTE_PARAM = "vote"
    
    static let USER_PICTURES = "api/v1/picture/list"
    static let USER_PICTURES_ORDER = "api/v1/picture/saveOrder"
    static let USER_PICTURES_UPDATE = "api/v1/picture/update"
    static let USER_PICTURES_DELETE = "api/v1/picture/delete"
    
    static let USER_MESSAGES_INBOX = "api/v1/message/inbox"
    static let USER_MESSAGES_OUTBOX = "api/v1/message/outbox"
    static let USER_MESSAGES_ARCHIVEBOX = "api/v1/message/archivebox"
    static let USER_MESSAGES_SEND = "api/v1/message/send"
    static let USER_MESSAGES_READ = "api/v1/message/read"
    static let USER_MESSAGES_DELETE = "api/v1/message/delete"
    static let USER_MESSAGES_ARCHIVE = "api/v1/message/archiveUser"
    
    static let USER_CONVERSATION_DELETE = "api/v1/conversation/delete"
    static let USER_CONVERSATION = "api/v1/conversation"
    
    static let USER_NEW_TOKEN = "token.php"
    
    // MARK: - User lists calls
    static let USER_VISITORS = "api/v1/user/visitors"
    static let USER_VISITED = "api/v1/user/visited"
    static let USER_FAVOURITES = "api/v1/user/favourites"
    static let V1_FAVOURITES = "api/v1/favourites"
    static let USER_BLOCKED = "api/v1/user/blocked"
    static let USER_WHOWANTSTOMEETME = "api/v1/user/whowantstomeetme"
    static let USER_IWANTTOMEET = "api/v1/user/iwanttomeet"
    static let USER_ONLINE = "api/v1/user/online"
    static let USER_ONLINE_FILTER = "api/v1/user/online/filter"
    static let USER_NEARBY = "api/v1/user/nearby"
    static let USER_NEW = "api/v1/user/new"
    static let USER_TOP = "api/v1/user/top"
    static let USER_ACTIVE = "api/v1/user/active"
    
    // MARK: - Sexy or Not
    static let PICTURE_RATE = "api/v1/picture/rate"
    static let PICTURE_SEXY_OR_NOT = "api/v1/picture/sexyornot"
    
    // MARK: - User profile  and action calls
    static let USER_PROFILE_UPDATE = "api/v1/user/update"
    static let USER_PROFILE_SUGGESTIONS = "api/getLocalValues.php"
    static let USER_METAPROFILE = "api/metaProfile.php"
    static let USER_QUESTIONS = "api/v1/user/questions"
    static let USER_SEARCH = "api/v1/user/search"
    static let USER_PICTURE_SEARCH = "api/v1/picture/search"
    static let USER_ACTION = "api/v1/user/action"
    static let USER_REPORT = "api/v1/user/report"
    
    // MARK: - Signup, login and recover passwords calls
    static let USER_LOGIN = "api/v1/token"
    static let USER_RESET_PASSWORD = "api/v1/user/reset-password"
    static let USER_CHECKFIELD = "api/checkField.php"
    static let USER_EMAIL_CHECK = "api/checkField.php"
    static let USER_LOCATION_AUTOCOMPLETE = "api/getLocations.php"
    static let USER_FILE_UPLOAD = "api/v1/picture/upload"
	static let TROUBLESHOOT = "api/v1/signupFeedback";
	static let TROUBLESHOOT_EMAIL_PARAM = "email";
	static let TROUBLESHOOT_MESSAGE_PARAM = "message";
	static let TROUBLESHOOT_VERSION_PARAM = "sdk";
	static let TROUBLESHOOT_DOMAIN_PARAM = "domain";
	static let TROUBLESHOOT_ANALYTICS_CATEGORY = "Signup troubleshoot";
	static let TROUBLESHOOT_ANALYTICS_SENT = "Troubleshoot sent";
    
    // MARK: - Feedback and Settings calls
    static let USER_FEEDBACK_CATEGORIES = "/api/v1/feedback/categories"
    static let USER_SEND_FEEDBACK = "api/v1/feedback"
    static let USER_NOTIFICATIONS = "api/v1/user/notifications"
    static let USER_SETTINGS = "api/v1/user/settings"
    static let USER_VISIBILITY_OPTIONS = "api/v1/user/visibility/options"
    static let USER_CONTACTIBILITY_OPTIONS = "api/v1/user/contactability/options"
    static let USER_CONTACTIBILITY = "api/v1/user/contactability"
    static let USER_VISIBILITY = "api/v1/user/visibility"
    static let USER_EMAIL_ADD = "api/v1/email/add"
    static let USER_PHONE_ADD = "api/v1/phone/add"
    static let USER_CONFIRM_CODE = "api/v1/email/check"
    static let USER_CONFIRM_PHONE = "api/v1/phone/check"
    static let USER_PHONE_STATUS = "api/v1/phone/status"
    static let USER_EMAIL_STATUS = "api/v1/email/status"
    static let USER_NOTIFICATION_MEDIUM = "api/v1/user/notificationMedium"
    static let USER_CHANGE_PASSWORD = "api/v1/user/changePassword"
    static let USER_DELETE = "api/v1/user/delete"
}

class WebResult<T> {
    var value: T?
    var array: Array<T> = []
    init(value: T?, array: Array<T>) {
        self.value = value
        self.array = array
    }
    init(value: T?) {
        self.value = value
    }
}
enum ConvertingError : ErrorType {
    case UnableToConvertJson
    case UnableToConvertJsonParsed
}
class Webservice {
    static func toJson(value: AnyObject) throws -> Genome.JSON {
        if let json = value as? Genome.JSON {
            return json
        } else {
            throw ConvertingError.UnableToConvertJson
        }
    }
    private static var requestsForKey: [String: Request] = [:]
    class func cancelRequestForKey(key: String) {
        if let request = requestsForKey[key] {
            request.cancel()
            requestsForKey.removeValueForKey(key)
        }
    }
    
    // MARK: - Authenticated request with Auth access_token
    class func authenticatedRequest<T: BasicMappable>(urlString: String, params: [String: AnyObject]?, animated: Bool, key: String? = nil) -> Future<WebResult<T>, NSError> {
        return authenticatedRequest(urlString, params: params, paramsString: nil, animated: animated, key: key)
    }
	class func authenticatedRequest<T: BasicMappable>(urlString: String, params: [String: AnyObject]?, paramsString: AnyObject?, animated: Bool, key: String? = nil) -> Future<WebResult<T>, NSError> {
        print(urlString)
        var request: NSURLRequest!
        if let prmString = paramsString {
            let jRequest = NSMutableURLRequest(URL: NSURL(string:urlString)!)
            jRequest.HTTPMethod = "POST"
            jRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            jRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            jRequest.setValue(FBNet.UserAgent, forHTTPHeaderField: "User-Agent")
			jRequest.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(prmString, options: NSJSONWritingOptions.init(rawValue: 0));
			
			
            request = jRequest
        }else{
            let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
            mutableURLRequest.HTTPMethod = "POST"
            let headers = ["User-Agent": FBNet.UserAgent]
            for (headerField, headerValue) in headers {
                mutableURLRequest.setValue(headerValue, forHTTPHeaderField: headerField)
            }
            let encoding: ParameterEncoding = .URL
            request = encoding.encode(mutableURLRequest, parameters: params).0
        }
        return authRequest(request, animated: animated, key: key)
    }
	
    
    // MARK: - Authenticated request with Auth access_token
    class func authenticatedRequestWithJson<T: BasicMappable>(urlString: String, params: [String: AnyObject]?, animated: Bool, key: String? = nil) -> Future<WebResult<T>, NSError> {
        return authenticatedRequestWithJson(urlString, params: params, paramsString: nil, animated: animated, key: key)
    }
    class func authenticatedRequestWithJson<T: BasicMappable>(urlString: String, params: [String: AnyObject]?, paramsString: AnyObject?, animated: Bool, key: String? = nil) -> Future<WebResult<T>, NSError> {
        print(urlString)
        var request: NSURLRequest!
        if let prmString = paramsString {
            let jRequest = NSMutableURLRequest(URL: NSURL(string:urlString)!)
            jRequest.HTTPMethod = "POST"
            jRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            jRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            jRequest.setValue(FBNet.UserAgent, forHTTPHeaderField: "User-Agent")
            
            jRequest.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(prmString, options: .PrettyPrinted)
            
            request = jRequest
        }else{
            let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
            mutableURLRequest.HTTPMethod = "POST"
            let headers = ["Accept":"application/json", "Content-Type":"application/json", "User-Agent": FBNet.UserAgent]
            for (headerField, headerValue) in headers {
                mutableURLRequest.setValue(headerValue, forHTTPHeaderField: headerField)
            }
            let encoding: ParameterEncoding = .JSON
            request = encoding.encode(mutableURLRequest, parameters: params).0
        }
        return authRequest(request, animated: animated, key: key)
    }
    class func authRequest<T: BasicMappable>(request: NSURLRequest, animated: Bool, key: String? = nil) -> Future<WebResult<T>, NSError>  {
        let promise = Promise<WebResult<T>, NSError>()
        showBlocking(animated)
        AuthMe.getAuthenticatedRequest(request).onSuccess(callback: { (request) -> Void in
            let manager = Alamofire.Manager.sharedInstance
            let alamofireRequest = manager.request(request).responseJSON { (response) -> Void in
//                print(response.request)  // original URL request
//                print(response.response) // URL response
//                print(response.data)     // server data
//                print(response.result)   // result of response serialization
                Async.background {
                    //let dataString = NSString(data: response.data!, encoding: NSUTF8StringEncoding)
                    //print(dataString)
                    mapResult(response, promise: promise)
                    }.main{
                        closeBlocking(animated)
                }
            }
            if let keyForRequest = key {
                self.requestsForKey[keyForRequest] = alamofireRequest
            }
            GoogleAnalitics.send(GoogleAnalitics.Api.Category, action: GoogleAnalitics.Api.NORMAL)
        }).onFailure(callback: { (error) -> Void in
            handleError(error)
            closeBlocking(animated)
            promise.failure(error)
        })
        return promise.future
    }
    
    // MARK: - This request not contains Auth parameters
    class func request<T: BasicMappable>(urlString: String, params: [String: AnyObject]?, animated: Bool) -> Future<WebResult<T>, NSError> {
        print(urlString)
        let promise = Promise<WebResult<T>, NSError>()
        showBlocking(animated)
        Alamofire.request(.POST, urlString, parameters: params, encoding: .URL, headers: ["User-Agent": FBNet.UserAgent]).responseJSON { (response) -> Void in
            Async.background {
                //let dataString = NSString(data: response.data!, encoding: NSUTF8StringEncoding)
                //print(dataString)
                mapResult(response, promise: promise)
                }.main{
                    closeBlocking(animated)
            }
        }
        return promise.future
    }
    
    // MARK: - Request with params in url
    class func requestWithUrlParams<T: BasicMappable>(url: String, params: [String: AnyObject]?, animated: Bool) -> Future<WebResult<T>, NSError> {
        var urlString = url
        print(urlString)
        let promise = Promise<WebResult<T>, NSError>()
        if let parameters = params where parameters.count > 0 {
            urlString += "?"
            for (key, value) in parameters {
                urlString += key + "=" + String(value) + "&"
            }
        }
        showBlocking(animated)
        Alamofire.request(.POST, urlString, parameters: nil, encoding: .URL, headers: ["User-Agent": FBNet.UserAgent]).responseJSON { (response) -> Void in
            Async.background {
                //let dataString = NSString(data: response.data!, encoding: NSUTF8StringEncoding)
                //print(dataString)
                mapResult(response, promise: promise)
                }.main{
                    closeBlocking(animated)
            }
        }
        return promise.future
    }
    
    // MARK: - JSON sending request
    class func requestWithJson<T: BasicMappable>(urlString: String, params: [String: AnyObject]?, animated: Bool) -> Future<WebResult<T>, NSError> {
        let promise = Promise<WebResult<T>, NSError>()
        showBlocking(animated)
        jsonRequest(urlString, params: params) { (response) -> () in
            mapResult(response, promise: promise)
            closeBlocking(animated)
        }
        return promise.future
    }
    class func jsonRequest(urlString: String, params: [String: AnyObject]?, completition: ((Response<AnyObject, NSError>)->())?) {
        print(urlString)
        Alamofire.request(.POST, urlString, parameters: params, encoding: .JSON, headers: ["Accept":"application/json", "Content-Type":"application/json", "User-Agent": FBNet.UserAgent]).responseJSON { (response) -> Void in
            //let dataString = NSString(data: response.data!, encoding: NSUTF8StringEncoding)
            //print(dataString)
            completition?(response)
        }
    }
    
    // MARK: - Error handling
    class func handleError(error: ErrorType) {
        print(error)
        GoogleAnalitics.send(GoogleAnalitics.Api.Category, action: GoogleAnalitics.Api.ERROR_GENERAL)
    }
    
    // MARK: - progress HUD
    private static var isBlocked = false
    private static var blockCount: Int = 0 {
        didSet {
            if !isBlocked && blockCount > 0 {
                isBlocked = true
                MRProgressOverlayView.showOverlayAddedTo(FBoxHelper.getWindow(), title: "", mode: .Indeterminate, animated: true)
            }else if isBlocked && blockCount == 0 {
                isBlocked = false
                MRProgressOverlayView.dismissOverlayForView(FBoxHelper.getWindow(), animated: true)
            }
        }
    }
    class func showBlocking(animated: Bool) {
        if animated {
            self.blockCount += 1
        }
    }
    class func closeBlocking(animated: Bool) {
        if animated {
            self.blockCount -= 1
            if self.blockCount < 0 {
                print("blockCount < 0")
                self.blockCount = 0
            }
        }
    }
    
    // MARK: - mapping the results
    private class func mapResult<T: BasicMappable>(response: Response<AnyObject, NSError>, promise: Promise<WebResult<T>, NSError>) {
        switch response.result {
        case .Success(let value):
            Async.background {
                do {
                    if let array = value as? NSArray {
                        var resultArray: Array<T> = []
                        for arrayValue in array {
                            let json = try toJson(arrayValue)
                            let resultObject = try T.mappedInstance(json)
                            resultArray.append(resultObject)
                        }
                        Async.main {
                            promise.success(WebResult(value: nil, array: resultArray))
                        }
                    }else{
                        let json = try toJson(value)
                        let resultObject = try T.mappedInstance(json)
                        Async.main {
                            promise.success(WebResult(value: resultObject))
                        }
                    }
                } catch {
                    handleError(error)
                    GoogleAnalitics.send(GoogleAnalitics.Api.Category, action: GoogleAnalitics.Api.INVALID_JSON)
                    Async.main {
                        promise.failure(NSError(domain: "UnableToConvertJson", code: -1, userInfo: nil))
                    }
                }
            }
        case .Failure(let error):
            handleError(error)
            promise.failure(error)
        }
    }
}