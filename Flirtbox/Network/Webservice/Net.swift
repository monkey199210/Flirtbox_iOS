//
//  Net.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 24.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import Foundation
import BrightFutures

class Net {
    private static let kMeRequestKey = "kMeRequestKey"
    class func me() -> Future<FBUser, NSError> {
        let promise = Promise<FBUser, NSError>()
        let urlString = String.FBURL(FBNet.ME)
        Webservice.cancelRequestForKey(kMeRequestKey)
        Webservice.authenticatedRequest(urlString, params: nil, animated: false, key: kMeRequestKey).onSuccess { (result: WebResult<FBUser>) -> Void in
            promise.success(result.value!)
        }.onFailure { (error) -> Void in
            print("Error: \(error)")
            promise.failure(error)
        }
        return promise.future
    }
	
	// MARK: - SIGN-UP
    class func userData(username: String, animated: Bool = false) -> Future<FBUser, NSError> {
        let promise = Promise<FBUser, NSError>()
        let urlString = String.FBURL(FBNet.USER_DATA)
        Webservice.authenticatedRequest(urlString, params: ["username": username], animated: animated).onSuccess { (result: WebResult<FBUser>) -> Void in
            promise.success(result.value!)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func resetPassword(email: String) -> Future<Bool, NSError> {
        let promise = Promise<Bool, NSError>()
        let urlString = String.FBURL(FBNet.USER_RESET_PASSWORD)
        Webservice.request(urlString, params: ["email":email], animated: true).onSuccess { (result: WebResult<FBResult>) -> Void in
            if result.value?.status == 200 {
                promise.success(true)
            }else{
                let error = NSError(domain: result.value!.message, code: 1, userInfo: nil)
                promise.failure(error)
            }
        }.onFailure { (error) -> Void in
            print("Error: \(error)")
            promise.failure(error)
        }
        return promise.future
    }
    class func checkUsernameField(value: String) -> Future<Bool, NSError> {
        let promise = Promise<Bool, NSError>()
        let urlString = String.FBURL(FBNet.USER_CHECKFIELD)
        Webservice.request(urlString, params: [FBNet.CHECK_PARAM_USERNAME:value, FBNet.CHECK_PARAM_TYPE:FBNet.CHECK_PARAM_USERNAME], animated: false).onSuccess { (result: WebResult<FBValid>) -> Void in
            promise.success(result.value!.valid)
        }.onFailure { (error) -> Void in
            print("Error: \(error)")
            promise.failure(error)
        }
        return promise.future
    }
    class func checkEmailField(value: String) -> Future<Bool, NSError> {
        let promise = Promise<Bool, NSError>()
        let urlString = String.FBURL(FBNet.USER_EMAIL_CHECK)
        Webservice.request(urlString, params: [FBNet.CHECK_PARAM_EMAIL:value, FBNet.CHECK_PARAM_TYPE:FBNet.CHECK_PARAM_EMAIL], animated: false).onSuccess { (result: WebResult<FBValid>) -> Void in
            promise.success(result.value!.valid)
        }.onFailure { (error) -> Void in
            print("Error: \(error)")
            promise.failure(error)
        }
        return promise.future
    }
    class func getLocations(value: String) -> Future<Array<FBPlace>, NSError> {
        let promise = Promise<Array<FBPlace>, NSError>()
        let urlString = String.FBURL(FBNet.USER_LOCATION_AUTOCOMPLETE)
        Webservice.requestWithUrlParams(urlString, params: [FBNet.LOCATION_PARAM:value], animated: false).onSuccess { (result: WebResult<FBPlace>) -> Void in
            promise.success(result.array)
        }.onFailure { (error) -> Void in
            print("Error: \(error)")
            promise.failure(error)
        }
        return promise.future
    }
//	Map<String, String> map = new LinkedHashMap<>();
//	map.put("email", email);
//	map.put("message", message);
//	map.put("sdk", Build.VERSION.SDK_INT + "");
//	map.put("domain", FlirtboxApplication.currentBaseUrl);
	class func sendTroubleshoot(email : String, message : String)->Future<Bool, NSError>{
		let promise = Promise<Bool, NSError>();
		let urlString = String.FBURL(FBNet.TROUBLESHOOT);
		var params: [String: String] = [:];
		params[FBNet.TROUBLESHOOT_EMAIL_PARAM] = email;
		params[FBNet.TROUBLESHOOT_MESSAGE_PARAM] = message;
		params[FBNet.TROUBLESHOOT_VERSION_PARAM] = UIDevice.currentDevice().systemVersion;
		params[FBNet.TROUBLESHOOT_DOMAIN_PARAM] = String.FBURL("");
		Webservice.request(urlString, params: params, animated: true).onSuccess {
			(result: WebResult<FBValid>) -> Void in
				promise.success(result.value!.valid)
			}.onFailure { (error) -> Void in
				print("Error: \(error)")
				promise.failure(error)
		}
		return promise.future;
	}
    // MARK: - Messages & Conversations
    class func inbox(offset: Int?, limit: Int?) -> Future<Array<FBMessage>, NSError> {
        let promise = Promise<Array<FBMessage>, NSError>()
        let urlString = String.FBURL(FBNet.USER_MESSAGES_INBOX)
        var params: [String: String] = [:]
        if let paramOffset = offset {
            params[FBNet.OFFSET_PARAM] = String(paramOffset)
        }
        if let paramLimit = limit {
            params[FBNet.LIMIT_PARAM] = String(paramLimit)
        }
        Webservice.authenticatedRequest(urlString, params: params, animated: false).onSuccess { (result: WebResult<FBMessage>) -> Void in
            promise.success(result.array)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func outbox(offset: Int?, limit: Int?) -> Future<Array<FBMessage>, NSError> {
        let promise = Promise<Array<FBMessage>, NSError>()
        let urlString = String.FBURL(FBNet.USER_MESSAGES_OUTBOX)
        var params: [String: String] = [:]
        if let paramOffset = offset {
            params[FBNet.OFFSET_PARAM] = String(paramOffset)
        }
        if let paramLimit = limit {
            params[FBNet.LIMIT_PARAM] = String(paramLimit)
        }
        Webservice.authenticatedRequest(urlString, params: params, animated: false).onSuccess { (result: WebResult<FBMessage>) -> Void in
            promise.success(result.array)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func archivebox(offset: Int?, limit: Int?) -> Future<Array<FBMessage>, NSError> {
        let promise = Promise<Array<FBMessage>, NSError>()
        let urlString = String.FBURL(FBNet.USER_MESSAGES_ARCHIVEBOX)
        var params: [String: String] = [:]
        if let paramOffset = offset {
            params[FBNet.OFFSET_PARAM] = String(paramOffset)
        }
        if let paramLimit = limit {
            params[FBNet.LIMIT_PARAM] = String(paramLimit)
        }
        Webservice.authenticatedRequest(urlString, params: params, animated: false).onSuccess { (result: WebResult<FBMessage>) -> Void in
            promise.success(result.array)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func sendMessage(toUser: String, message: String) -> Future<Bool, NSError> {
        let promise = Promise<Bool, NSError>()
        let urlString = String.FBURL(FBNet.USER_MESSAGES_SEND)
        Webservice.authenticatedRequestWithJson(urlString, params: [FBNet.TOUSER_PARAM: toUser, FBNet.MESSAGE_PARAM: message], animated: false).onSuccess { (result: WebResult<FBMessage>) -> Void in
			if(result.value != nil)
			{
				promise.success(true);
			}
			else{
//				let error : NSError = result.value!.message != nil ? NSError(domain: result.value!.message!, code: 1, userInfo: nil) : NSError(domain: "Sending", code: 1, userInfo: nil)
				promise.failure(NSError(domain: "", code: 1, userInfo: nil));
			}
//			if let status = result.value!.status where status == 200{
//                promise.success(true)
//            }else{
//                let error = result.value!.message != nil ? NSError(domain: result.value!.message!, code: 1, userInfo: nil) : NSError(domain: "Sending", code: 1, userInfo: nil)
//                promise.failure(error)
//            }
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func conversation(uname: String, offset: Int?, limit: Int?) -> Future<Array<FBConversation>, NSError> {
        let promise = Promise<Array<FBConversation>, NSError>()
        let urlString = String.FBURL(FBNet.USER_CONVERSATION)
        var params: [String: String] = [FBNet.USERNAME_PARAM:uname]
        if let paramOffset = offset {
            params[FBNet.OFFSET_PARAM] = String(paramOffset)
        }
        if let paramLimit = limit {
            params[FBNet.LIMIT_PARAM] = String(paramLimit)
        }
        Webservice.authenticatedRequest(urlString, params: params, animated: false).onSuccess { (result: WebResult<FBConversation>) -> Void in
            promise.success(result.array)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func deleteMessage(ids: Array<Int>) {
        let urlString = String.FBURL(FBNet.USER_MESSAGES_DELETE)
        Webservice.authenticatedRequest(urlString, params: nil, paramsString: ids, animated: false).onSuccess { (result: WebResult<FBResponce>) -> Void in
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
        }
    }
    class func readMessage(ids: Array<Int>) {
        let urlString = String.FBURL(FBNet.USER_MESSAGES_READ)
        Webservice.authenticatedRequest(urlString, params: nil, paramsString: ids, animated: false).onSuccess { (result: WebResult<FBResponce>) -> Void in
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
        }
    }
    class func archiveConversation(ids: Array<Int>) -> Future<Bool, NSError> {
        let promise = Promise<Bool, NSError>()
        let urlString = String.FBURL(FBNet.USER_MESSAGES_ARCHIVE)
        Webservice.authenticatedRequest(urlString, params: nil, paramsString: ids, animated: false).onSuccess { (result: WebResult<FBResponce>) -> Void in
            promise.success(true)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func deleteConversation(uname: String) -> Future<Bool, NSError> {
        let promise = Promise<Bool, NSError>()
        let urlString = String.FBURL(FBNet.USER_CONVERSATION_DELETE)
        Webservice.authenticatedRequest(urlString, params: [FBNet.USERNAME_PARAM: uname], animated: false).onSuccess { (result: WebResult<FBResponce>) -> Void in
            promise.success(true)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    
    // MARK: - Work with images
    private static let kPictureListRequestKey = "kPictureListRequestKey"
    class func pictureList()  -> Future<[FBPicture], NSError> {
        let promise = Promise<[FBPicture], NSError>()
        let urlString = String.FBURL(FBNet.USER_PICTURES)
        Webservice.cancelRequestForKey(kPictureListRequestKey)
        Webservice.authenticatedRequest(urlString, params: nil, animated: false, key: kPictureListRequestKey).onSuccess { (result: WebResult<FBPicture>) -> Void in
            promise.success(result.array)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func uploadImage(image: UIImage, progressCallback: (Double->Void)? = nil) -> Future<Bool, NSError> {
        let imageData = NSData(data: UIImageJPEGRepresentation(image, 1.0)!)
        let urlString = String.FBURL(FBNet.USER_FILE_UPLOAD)
        return ImageUploader.uploadImage(urlString, imageData: imageData, progressCallback: progressCallback)
    }
    class func deletePicture(ids: Array<Int>) -> Future<Bool, NSError> {
        let promise = Promise<Bool, NSError>()
        let urlString = String.FBURL(FBNet.USER_PICTURES_DELETE)
        Webservice.authenticatedRequestWithJson(urlString, params: nil, paramsString: ids, animated: true).onSuccess { (result: WebResult<FBResponce>) -> Void in
            promise.success(true)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func orderPicture(ids: Array<Int>) {
        let urlString = String.FBURL(FBNet.USER_PICTURES_ORDER)
        Webservice.authenticatedRequestWithJson(urlString, params: nil, paramsString: ids, animated: false).onSuccess { (result: WebResult<FBResponce>) -> Void in
            FBEvent.pictChanged(true)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
        }
    }
//	/api/v1/picture/update -d '{"picture":{"visibility":"1","ratable":"0","description":"pssst!!!","picid":"1999760"}'
	class func updatePicture(picid: String, ratable: Int, visibility: Visibility, description : String = "") -> Future<Bool, NSError> {
        let promise = Promise<Bool, NSError>()
        let urlString = String.FBURL(FBNet.USER_PICTURES_UPDATE)
        let updateDict = ["picture": ["picid":picid, "ratable": ratable, "visibility": visibility.rawValue, "description": description]]
        Webservice.authenticatedRequestWithJson(urlString, params: nil, paramsString: updateDict, animated: false).onSuccess { (result: WebResult<FBResponce>) -> Void in
            promise.success(true)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func updatePictureDescription(picid: String, description: String) -> Future<Bool, NSError> {
        let promise = Promise<Bool, NSError>()
        let urlString = String.FBURL(FBNet.USER_PICTURES_UPDATE)
        let updateDict = ["picture": ["picid":picid, "description": description]]
        Webservice.authenticatedRequestWithJson(urlString, params: nil, paramsString: updateDict, animated: false).onSuccess { (result: WebResult<FBResponce>) -> Void in
            promise.success(true)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    
    // MARK: - User lists calls
    private static let kVisitorsRequestKey = "kVisitorsRequestKey"
    class func visitors(offset: Int, limit: Int) -> Future<[FBSearchedUser], NSError> {
        let promise = Promise<[FBSearchedUser], NSError>()
        let urlString = String.FBURL(FBNet.USER_VISITORS)
        Webservice.cancelRequestForKey(kVisitorsRequestKey)
        Webservice.authenticatedRequest(urlString, params: [FBNet.LIMIT_PARAM: String(limit), FBNet.OFFSET_PARAM: String(offset)], animated: false, key: kVisitorsRequestKey).onSuccess { (result: WebResult<FBSearchedUser>) -> Void in
            promise.success(result.array)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    private static let kVisitedRequestKey = "kVisitedRequestKey"
    class func visited(offset: Int, limit: Int) -> Future<[FBSearchedUser], NSError> {
        let promise = Promise<[FBSearchedUser], NSError>()
        let urlString = String.FBURL(FBNet.USER_VISITED)
        Webservice.cancelRequestForKey(kVisitedRequestKey)
        Webservice.authenticatedRequest(urlString, params: [FBNet.LIMIT_PARAM: String(limit), FBNet.OFFSET_PARAM: String(offset)], animated: false, key: kVisitedRequestKey).onSuccess { (result: WebResult<FBSearchedUser>) -> Void in
            promise.success(result.array)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    private static let kFavouritesRequestKey = "kFavouritesRequestKey"
    class func favourites(offset: Int, limit: Int) -> Future<[FBSearchedUser], NSError> {
        let promise = Promise<[FBSearchedUser], NSError>()
        let urlString = String.FBURL(FBNet.USER_FAVOURITES)
        Webservice.cancelRequestForKey(kFavouritesRequestKey)
        Webservice.authenticatedRequest(urlString, params: [FBNet.LIMIT_PARAM: String(limit), FBNet.OFFSET_PARAM: String(offset)], animated: false, key: kFavouritesRequestKey).onSuccess { (result: WebResult<FBSearchedUser>) -> Void in
            promise.success(result.array)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func v1Favourites() {
        let urlString = String.FBURL(FBNet.V1_FAVOURITES)
        Webservice.authenticatedRequest(urlString, params: nil, animated: false).onSuccess { (result: WebResult<FBLightUser>) -> Void in
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
        }
    }
    private static let kBlockedRequestKey = "kBlockedRequestKey"
    class func blocked(offset: Int, limit: Int) -> Future<[FBSearchedUser], NSError> {
        let promise = Promise<[FBSearchedUser], NSError>()
        let urlString = String.FBURL(FBNet.USER_BLOCKED)
        Webservice.cancelRequestForKey(kBlockedRequestKey)
        Webservice.authenticatedRequest(urlString, params: [FBNet.LIMIT_PARAM: String(limit), FBNet.OFFSET_PARAM: String(offset)], animated: false, key: kBlockedRequestKey).onSuccess { (result: WebResult<FBSearchedUser>) -> Void in
            promise.success(result.array)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    private static let kwhoWantsRequestKey = "kwhoWantsRequestKey"
    class func whoWantsToMeetMe(offset: Int, limit: Int) -> Future<[FBSearchedUser], NSError> {
        let promise = Promise<[FBSearchedUser], NSError>()
        let urlString = String.FBURL(FBNet.USER_WHOWANTSTOMEETME)
        Webservice.cancelRequestForKey(kwhoWantsRequestKey)
        Webservice.authenticatedRequest(urlString, params: [FBNet.LIMIT_PARAM: String(limit), FBNet.OFFSET_PARAM: String(offset)], animated: false, key: kwhoWantsRequestKey).onSuccess { (result: WebResult<FBSearchedUser>) -> Void in
            promise.success(result.array)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    private static let kIWantToMeetRequestKey = "kIWantToMeetRequestKey"
    class func iWantToMeet(offset: Int, limit: Int) -> Future<[FBSearchedUser], NSError> {
        let promise = Promise<[FBSearchedUser], NSError>()
        let urlString = String.FBURL(FBNet.USER_IWANTTOMEET)
        Webservice.cancelRequestForKey(kIWantToMeetRequestKey)
        Webservice.authenticatedRequest(urlString, params: [FBNet.LIMIT_PARAM: String(limit), FBNet.OFFSET_PARAM: String(offset)], animated: false, key: kIWantToMeetRequestKey).onSuccess { (result: WebResult<FBSearchedUser>) -> Void in
            promise.success(result.array)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    private static let kOnlineRequestKey = "kOnlineRequestKey"
    class func online(offset: Int, limit: Int) -> Future<[FBSearchedUser], NSError> {
        let promise = Promise<[FBSearchedUser], NSError>()
        let urlString = String.FBURL(FBNet.USER_ONLINE)
        Webservice.cancelRequestForKey(kOnlineRequestKey)
        Webservice.authenticatedRequest(urlString, params: [FBNet.LIMIT_PARAM: String(limit), FBNet.OFFSET_PARAM: String(offset)], animated: false, key: kOnlineRequestKey).onSuccess { (result: WebResult<FBSearchedUser>) -> Void in
            promise.success(result.array)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    private static let kOnlineFilterRequestKey = "kOnlineFilterRequestKey"
    class func onlineFilter(offset: Int, limit: Int, days: Int = 90) -> Future<[FBSearchedUser], NSError> {
        let promise = Promise<[FBSearchedUser], NSError>()
        let urlString = String.FBURL(FBNet.USER_ONLINE_FILTER)
        Webservice.cancelRequestForKey(kOnlineFilterRequestKey)
        Webservice.authenticatedRequest(urlString, params: [FBNet.LIMIT_PARAM: String(limit), FBNet.OFFSET_PARAM: String(offset), FBNet.DAYS_PARAM: String(days)], animated: false, key: kOnlineFilterRequestKey).onSuccess { (result: WebResult<FBSearchedUser>) -> Void in
            promise.success(result.array)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    
    // MARK: - Search API
    private static let kSearchRequestKey = "kSearchRequestKey"
    class func search(distance: Double, offset: Int, limit: Int, lat: Double, lon: Double, sortField: SortField?, sortDesc: Bool? = nil, minRatings: Int? = nil, gender: Gender? = nil, minAge: Int? = nil, maxAge: Int? = nil) -> Future<[FBSearchedUser], NSError> {
        let promise = Promise<[FBSearchedUser], NSError>()
        let urlString = String.FBURL(FBNet.USER_SEARCH)
        var params = [FBNet.LATITUDE_PARAM:String(lat), FBNet.LONGITUDE_PARAM:String(lon), FBNet.DISTANCE_PARAM: String(distance), FBNet.OFFSET_PARAM: String(offset), FBNet.LIMIT_PARAM: String(limit)]
        if let sortField = sortField {
            params[FBNet.SORTFIELD_PARAM] = sortField.rawValue
        }
        if let sortDesc = sortDesc {
            params[FBNet.SORTDESC_PARAM] = sortDesc ? "true" : "false"
        }
        if let minRatings = minRatings {
            params[FBNet.MINRATINGS_PARAM] = String(minRatings)
        }
        if let gender = gender {
            params[FBNet.PROFILE_GENDER_PARAM] = gender.rawValue
        }
        if let minAge = minAge {
            params[FBNet.MINAGE_PARAM] = String(minAge)
        }
        if let maxAge = maxAge {
            params[FBNet.MAXAGE_PARAM] = String(maxAge)
        }
        Webservice.cancelRequestForKey(kSearchRequestKey)
        Webservice.authenticatedRequestWithJson(urlString, params: params, animated: false, key: kSearchRequestKey).onSuccess { (result: WebResult<FBSearchedUser>) -> Void in
            promise.success(result.array)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    private static let kNearbyRequestKey = "kNearbyRequestKey"
    class func nearby(offset: Int, limit: Int) -> Future<[FBSearchedUser], NSError> {
        let promise = Promise<[FBSearchedUser], NSError>()
        let urlString = String.FBURL(FBNet.USER_NEARBY)
        Webservice.cancelRequestForKey(kNearbyRequestKey)
        Webservice.authenticatedRequestWithJson(urlString, params: [FBNet.LIMIT_PARAM: String(limit), FBNet.OFFSET_PARAM: String(offset)], animated: false, key: kNearbyRequestKey).onSuccess { (result: WebResult<FBSearchedUser>) -> Void in
            promise.success(result.array)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    private static let kNewRequestKey = "kNewRequestKey"
    class func new(offset: Int, limit: Int) -> Future<[FBSearchedUser], NSError> {
        let promise = Promise<[FBSearchedUser], NSError>()
        let urlString = String.FBURL(FBNet.USER_NEW)
        Webservice.cancelRequestForKey(kNewRequestKey)
        Webservice.authenticatedRequestWithJson(urlString, params: [FBNet.LIMIT_PARAM: String(limit), FBNet.OFFSET_PARAM: String(offset)], animated: false, key: kNewRequestKey).onSuccess { (result: WebResult<FBSearchedUser>) -> Void in
            promise.success(result.array)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    private static let kTopRequestKey = "kTopRequestKey"
    class func top(offset: Int, limit: Int) -> Future<[FBSearchedUser], NSError> {
        let promise = Promise<[FBSearchedUser], NSError>()
        let urlString = String.FBURL(FBNet.USER_TOP)
        Webservice.cancelRequestForKey(kTopRequestKey)
        Webservice.authenticatedRequestWithJson(urlString, params: [FBNet.LIMIT_PARAM: String(limit), FBNet.OFFSET_PARAM: String(offset)], animated: false, key: kTopRequestKey).onSuccess { (result: WebResult<FBSearchedUser>) -> Void in
            promise.success(result.array)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    private static let kActiveRequestKey = "kActiveRequestKey"
    class func active(offset: Int, limit: Int) -> Future<[FBSearchedUser], NSError> {
        let promise = Promise<[FBSearchedUser], NSError>()
        let urlString = String.FBURL(FBNet.USER_ACTIVE)
        Webservice.cancelRequestForKey(kActiveRequestKey)
        Webservice.authenticatedRequestWithJson(urlString, params: [FBNet.LIMIT_PARAM: String(limit), FBNet.OFFSET_PARAM: String(offset)], animated: false, key: kActiveRequestKey).onSuccess { (result: WebResult<FBSearchedUser>) -> Void in
            promise.success(result.array)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func pictureSearch(minRatings: Int?, offset: Int?, limit: Int?, days: Int?, distance: Int?, gender: String?, longitude: Double?, latitude: Double?, minAge: Int?, maxAge: Int?, minSent: Int?, minReceived: Int?, sortField: SortField?) -> Future<[FBSearchedUser], NSError> {
        let promise = Promise<[FBSearchedUser], NSError>()
        let urlString = String.FBURL(FBNet.USER_PICTURE_SEARCH)
        var params: [String: String] = [:]
        if let minReceived = minReceived {
            params[FBNet.MINRECEIVED_PARAM] = String(minReceived)
        }
        if let minSent = minSent {
            params[FBNet.MINSENT_PARAM] = String(minSent)
        }
        if let maxAge = maxAge {
            params[FBNet.MAXAGE_PARAM] = String(maxAge)
        }
        if let minAge = minAge {
            params[FBNet.MINAGE_PARAM] = String(minAge)
        }
        if let gender = gender {
            params[FBNet.PROFILE_GENDER_PARAM] = String(gender)
        }
        if let days = days {
            params[FBNet.DAYS_PARAM] = String(days)
        }
        if let limit = limit {
            params[FBNet.LIMIT_PARAM] = String(limit)
        }
        if let offset = offset {
            params[FBNet.OFFSET_PARAM] = String(offset)
        }
        if let distance = distance {
            params[FBNet.DISTANCE_PARAM] = String(distance)
        }
        if let longitude = longitude {
            params[FBNet.LONGITUDE_PARAM] = String(longitude)
        }
        if let latitude = latitude {
            params[FBNet.LATITUDE_PARAM] = String(latitude)
        }
        if let minRatings = minRatings {
            params[FBNet.MINRATINGS_PARAM] = String(minRatings)
        }
        if let sortField = sortField {
            params[FBNet.SORTFIELD_PARAM] = sortField.rawValue
            params[FBNet.SORTDESC_PARAM] = "true"
        }
        Webservice.authenticatedRequestWithJson(urlString, params: params, animated: false).onSuccess { (result: WebResult<FBSearchedUser>) -> Void in
            promise.success(result.array)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    
    // MARK: - User profile  and action calls
    class func localValues(categoryName: String?, animated: Bool = true, category: Int? = nil, gender: String? = nil) -> Future<[FBLocalValue], NSError> {
        let promise = Promise<[FBLocalValue], NSError>()
        let urlString = String.FBURL(FBNet.USER_PROFILE_SUGGESTIONS)
        var params: [String: String] = [:]
        if let categoryName = categoryName {
            params[FBNet.PROFILE_CATEGORY_PARAM] = categoryName
        }
        if let category = category {
            params[FBNet.PROFILE_CATEGORY] = String(category)
        }
        if let gender = gender {
            params[FBNet.PROFILE_GENDER_PARAM] = String(gender)
        }
        Webservice.requestWithUrlParams(urlString, params: params, animated: animated).onSuccess { (result: WebResult<FBLocalValue>) -> Void in
            promise.success(result.array)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func metaProfile() {
        let urlString = String.FBURL(FBNet.USER_METAPROFILE)
        Webservice.request(urlString, params: nil, animated: false).onSuccess { (result: WebResult<FBMetaResult>) -> Void in
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
        }
    }
    class func questions() -> Future<FBQuestions, NSError> {
        let promise = Promise<FBQuestions, NSError>()
        let urlString = String.FBURL(FBNet.USER_QUESTIONS)
        Webservice.authenticatedRequestNotMappable(urlString, params: nil, animated: false).onSuccess { (result: WebResult<FBQuestions>) -> Void in
            promise.success(result.value!)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func updateProfile(key: String, value: AnyObject?) -> Future<Bool, NSError> {
        let promise = Promise<Bool, NSError>()
        let urlString = String.FBURL(FBNet.USER_PROFILE_UPDATE)
        var params: [String: AnyObject] = [FBNet.KEY_PARAM:key]
        params[FBNet.VALUE_PARAM] = value
        Webservice.authenticatedRequestWithJson(urlString, params: params, animated: true).onSuccess { (result: WebResult<FBResponce>) -> Void in
            promise.success(true)
            FBEvent.profileUpdated(true)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func updateProfileLocation(lat: Double, lon: Double) -> Future<Bool, NSError> {
        let promise = Promise<Bool, NSError>()
        let urlString = String.FBURL(FBNet.USER_PROFILE_UPDATE)
        let params = [FBNet.SHORT_LATITUDE_PARAM: String(lat), FBNet.SHORT_LONGITUDE_PARAM: String(lon)]
        Webservice.authenticatedRequestWithJson(urlString, params: params, animated: false).onSuccess { (result: WebResult<FBResponce>) -> Void in
            promise.success(true)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func updateProfileRegID(registration_id: String, operatingSystem: String, operatingSystemVersion: String) -> Future<Bool, NSError> {
        let promise = Promise<Bool, NSError>()
        let urlString = String.FBURL(FBNet.USER_PROFILE_UPDATE)
        let params = [FBNet.REGID_PARAM: registration_id, FBNet.OPERATINGSYS_PARAM: operatingSystem, FBNet.OPERATINGSYS_VER_PARAM: operatingSystemVersion]
        Webservice.authenticatedRequestWithJson(urlString, params: params, animated: false).onSuccess { (result: WebResult<FBResponce>) -> Void in
            promise.success(true)
            FBEvent.profileUpdated(true)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func updateProfileQuestion(questionId: String, value: String) -> Future<Bool, NSError> {
        let promise = Promise<Bool, NSError>()
        let urlString = String.FBURL(FBNet.USER_PROFILE_UPDATE)
        var params: [String: String] = [FBNet.KEY_PARAM:Net.TagProfileItems.QUESTIONS.rawValue]
		params["id"] = questionId;
		params[FBNet.VALUE_PARAM] = value;
        Webservice.authenticatedRequestWithJson(urlString, params: params, animated: true).onSuccess { (result: WebResult<FBResponce>) -> Void in
            promise.success(true)
            FBEvent.profileUpdated(true)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func userAction(profile: String, action: UserAction) {
        let urlString = String.FBURL(FBNet.USER_ACTION)
        Webservice.authenticatedRequestWithJson(urlString, params: [action.rawValue:profile], animated: false).onSuccess { (result: WebResult<FBResponce>) -> Void in
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
        }
    }
    class func report(username: String, categoryId: ReportType, message: String) {
        let urlString = String.FBURL(FBNet.USER_REPORT)
        Webservice.authenticatedRequestWithJson(urlString, params: [FBNet.CHECK_PARAM_USERNAME: username, FBNet.CHECK_PARAM_CATEGORY: String(categoryId.rawValue), FBNet.MESSAGE_PARAM: message], animated: true).onSuccess { (result: WebResult<FBResponce>) -> Void in
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
        }
    }
    
    // MARK: - Feedback and Settings calls
    class func feedbackCategories() -> Future<[FBFeedbackCategory], NSError> {
        let promise = Promise<[FBFeedbackCategory], NSError>()
        let urlString = String.FBURL(FBNet.USER_FEEDBACK_CATEGORIES)
        Webservice.request(urlString, params: nil, animated: true).onSuccess { (result: WebResult<FBFeedbackCategory>) -> Void in
            promise.success(result.array)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func feedback(category: String, subject: String, message: String, username: String, email: String) -> Future<Bool, NSError> {
        let promise = Promise<Bool, NSError>()
        let urlString = String.FBURL(FBNet.USER_SEND_FEEDBACK)
        if AuthMe.isAuthenticated() {
            Webservice.authenticatedRequestWithJson(urlString, params:[FBNet.CHECK_PARAM_USERNAME: username, FBNet.EMAIL_PARAM: email, FBNet.PROFILE_CATEGORY: category, FBNet.SUBJECT_PARAM: subject, FBNet.MESSAGE_PARAM: message], animated: true).onSuccess { (result: WebResult<FBResponce>) -> Void in
                promise.success(true)
                }.onFailure { (error) -> Void in
                    print("Error: \(error)")
                    promise.failure(error)
            }
        }else {
            Webservice.requestWithJson(urlString, params: [FBNet.CHECK_PARAM_USERNAME: username, FBNet.EMAIL_PARAM: email, FBNet.PROFILE_CATEGORY: category, FBNet.SUBJECT_PARAM: subject, FBNet.MESSAGE_PARAM: message], animated: true).onSuccess { (result: WebResult<FBResponce>) -> Void in
                promise.success(true)
                }.onFailure { (error) -> Void in
                    print("Error: \(error)")
                    promise.failure(error)
            }
        }
        return promise.future
    }
    class func notifications() {
        let urlString = String.FBURL(FBNet.USER_NOTIFICATIONS)
        Webservice.authenticatedRequest(urlString, params: nil, animated: true).onSuccess { (result: WebResult<FBSettingsValue>) -> Void in
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
        }
    }
    class func updateNotifications(key: String, value: Bool) -> Future<Bool, NSError> {
        let promise = Promise<Bool, NSError>()
        let urlString = String.FBURL(FBNet.USER_NOTIFICATIONS)
        let boolValue = value ? "true" : "false"
        Webservice.authenticatedRequest(urlString, params: [FBNet.KEY_PARAM: key, FBNet.VALUE_PARAM: boolValue], animated: false).onSuccess { (result: WebResult<FBResponce>) -> Void in
            promise.success(true)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func settings(animated: Bool = true) -> Future<FBSettings, NSError> {
        let promise = Promise<FBSettings, NSError>()
        let urlString = String.FBURL(FBNet.USER_SETTINGS)
        Webservice.authenticatedRequestNotMappable(urlString, params: nil, animated: animated).onSuccess { (result: WebResult<FBSettings>) -> Void in
            promise.success(result.value!)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func updateSettings(key: String, value: Bool) -> Future<Bool, NSError> {
        let promise = Promise<Bool, NSError>()
        let urlString = String.FBURL(FBNet.USER_SETTINGS)
        let boolValue = value ? "true" : "false"
        Webservice.authenticatedRequest(urlString, params: [FBNet.KEY_PARAM: key, FBNet.VALUE_PARAM: boolValue], animated: false).onSuccess { (result: WebResult<FBResponce>) -> Void in
            promise.success(true)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func visibilityOptions() {
        let urlString = String.FBURL(FBNet.USER_VISIBILITY_OPTIONS)
        Webservice.authenticatedRequest(urlString, params: nil, animated: true).onSuccess { (result: WebResult<FBVisibilityOption>) -> Void in
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
        }
    }
    class func updateVisibility(visibility: Visibility) {
        let urlString = String.FBURL(FBNet.USER_VISIBILITY)
        Webservice.authenticatedRequest(urlString, params: [FBNet.VISIBILITY_PARAM: String(visibility.rawValue)], animated: true).onSuccess { (result: WebResult<FBResponce>) -> Void in
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
        }
    }
    class func contactibilityOptions() {
        let urlString = String.FBURL(FBNet.USER_CONTACTIBILITY_OPTIONS)
        Webservice.authenticatedRequest(urlString, params: nil, animated: true).onSuccess { (result: WebResult<FBVisibilityOption>) -> Void in
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
        }
    }
    class func updateContactibility(contact: Int) {
        let urlString = String.FBURL(FBNet.USER_CONTACTIBILITY)
        Webservice.authenticatedRequest(urlString, params: [FBNet.CONTACT_PARAM: String(contact)], animated: true).onSuccess { (result: WebResult<FBResponce>) -> Void in
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
        }
    }
    
    // MARK: - Confirmations
    class func sendemail(email: String) -> Future<Bool, NSError> {
        let promise = Promise<Bool, NSError>()
        let urlString = String.FBURL(FBNet.USER_EMAIL_ADD)
        Webservice.authenticatedRequest(urlString, params: [FBNet.EMAIL_PARAM: email], animated: true).onSuccess { (result: WebResult<FBResponce>) -> Void in
            promise.success(true)
            FBEvent.profileUpdated(true)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func emailcode(code: String) -> Future<FBResponce, NSError> {
        let promise = Promise<FBResponce, NSError>()
        let urlString = String.FBURL(FBNet.USER_CONFIRM_CODE)
        Webservice.authenticatedRequest(urlString, params: [FBNet.CODE_PARAM: code], animated: true).onSuccess { (result: WebResult<FBResponce>) -> Void in
            promise.success(result.value!)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func sendPhone(phone: String) -> Future<Bool, NSError> {
        let promise = Promise<Bool, NSError>()
        let urlString = String.FBURL(FBNet.USER_PHONE_ADD)
        Webservice.authenticatedRequest(urlString, params: [FBNet.PHONE_PARAM: phone], animated: true).onSuccess { (result: WebResult<FBResponce>) -> Void in
            promise.success(true)
            FBEvent.profileUpdated(true)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func confirmPhone(code: String) -> Future<Bool, NSError> {
        let promise = Promise<Bool, NSError>()
        let urlString = String.FBURL(FBNet.USER_CONFIRM_PHONE)
        Webservice.authenticatedRequest(urlString, params: [FBNet.CODE_PARAM: code], animated: true).onSuccess { (result: WebResult<FBResponce>) -> Void in
            promise.success(true)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func phoneStatus() -> Future<Bool, NSError> {
        let promise = Promise<Bool, NSError>()
        let urlString = String.FBURL(FBNet.USER_PHONE_STATUS)
        Webservice.authenticatedRequest(urlString, params: nil, animated: false).onSuccess { (result: WebResult<FBResponce>) -> Void in
            promise.success(true)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func emailStatus() -> Future<FBEmail, NSError> {
        let promise = Promise<FBEmail, NSError>()
        let urlString = String.FBURL(FBNet.USER_EMAIL_STATUS)
        Webservice.authenticatedRequest(urlString, params: nil, animated: false).onSuccess { (result: WebResult<FBEmail>) -> Void in
            promise.success(result.value!)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func notificationMedium(key: String? = nil, value: Bool? = nil) -> Future<[FBSettingsValue], NSError> {
        let promise = Promise<[FBSettingsValue], NSError>()
        let urlString = String.FBURL(FBNet.USER_NOTIFICATION_MEDIUM)
        var params: [String: String]? = nil
        if let key = key, let value = value {
            let boolValue = value ? "true" : "false"
            params = [FBNet.KEY_PARAM: key, FBNet.VALUE_PARAM: boolValue]
        }
        Webservice.authenticatedRequest(urlString, params: params, animated: false).onSuccess { (result: WebResult<FBSettingsValue>) -> Void in
            promise.success(result.array)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func changePassword(password: String) -> Future<Bool, NSError> {
        let promise = Promise<Bool, NSError>()
        let urlString = String.FBURL(FBNet.USER_CHANGE_PASSWORD)
        let params: [String: String] = [FBNet.PASSWORD_PARAM: password]
        Webservice.authenticatedRequest(urlString, params: params, animated: false).onSuccess { (result: WebResult<FBSettingsValue>) -> Void in
            promise.success(true)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func deleteMe(password: String) -> Future<Bool, NSError> {
        let promise = Promise<Bool, NSError>()
        let urlString = String.FBURL(FBNet.USER_DELETE)
        let params: [String: String] = [FBNet.PASSWORD_PARAM: password]
        Webservice.authenticatedRequest(urlString, params: params, animated: true).onSuccess { (result: WebResult<FBResponce>) -> Void in
            promise.success(true)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func rateRicture(picid: String, vote: Int) -> Future<Bool, NSError> {
        let promise = Promise<Bool, NSError>()
        let urlString = String.FBURL(FBNet.PICTURE_RATE)
        Webservice.authenticatedRequest(urlString, params: [FBNet.PICID_PARAM: picid, FBNet.VOTE_PARAM: String(vote)], animated: false).onSuccess { (result: WebResult<FBResponce>) -> Void in
            promise.success(true)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func sexyOrNot(longitude: Double, latitude: Double, distance: String, offset: Int, limit: Int) -> Future<[FBSexyOrNotUser], NSError> {
        let promise = Promise<[FBSexyOrNotUser], NSError>()
        let urlString = String.FBURL(FBNet.PICTURE_SEXY_OR_NOT)
        Webservice.authenticatedRequestWithJson(urlString, params: [FBNet.LONGITUDE_PARAM: longitude, FBNet.LATITUDE_PARAM: latitude, FBNet.DISTANCE_PARAM: distance, FBNet.OFFSET_PARAM: String(offset), FBNet.LIMIT_PARAM: String(limit), FBNet.SORTFIELD_PARAM: "sent", FBNet.MINRECEIVED_PARAM: "2", FBNet.MINSENT_PARAM: "5"], animated: false).onSuccess { (result: WebResult<FBSexyOrNotUser>) -> Void in
            promise.success(result.array)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func checkPass(username: String, password: String) -> Future<AuthResponce, NSError> {
        let promise = Promise<AuthResponce, NSError>()
        let urlString = String.FBURL(FBNet.USER_NEW_TOKEN)
        Webservice.request(urlString, params: ["grant_type": "password", "username": username, "password": password, "client_id": AuthConstants.clientId, "client_secret": AuthConstants.client_secret], animated: false).onSuccess { (result: WebResult<AuthResponce>) -> Void in
            promise.success(result.value!)
        }.onFailure { (error) -> Void in
            print("Error: \(error)")
            promise.failure(error)
        }
        return promise.future
    }
}