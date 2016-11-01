//
//  Webservice+.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 26.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import BrightFutures
import Async

//Webservice without Cenome, some responces can't be mapped
extension Webservice {
    // MARK: - Authenticated request with Auth access_token
    class func authenticatedRequestNotMappable<T: JsonParsed>(urlString: String, params: [String: String]?, animated: Bool) -> Future<WebResult<T>, NSError> {
        return authenticatedRequestNotMappable(urlString, params: params, paramsString: nil, animated: animated)
    }
    class func authenticatedRequestNotMappable<T: JsonParsed>(urlString: String, params: [String: String]?, paramsString: String?, animated: Bool) -> Future<WebResult<T>, NSError> {
        print(urlString)
        var request: NSURLRequest!
        if let prmString = paramsString {
            let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
            mutableURLRequest.HTTPMethod = "POST"
            let headers = ["Accept":"application/json", "Content-Type":"application/json", "User-Agent": FBNet.UserAgent]
            for (headerField, headerValue) in headers {
                mutableURLRequest.setValue(headerValue, forHTTPHeaderField: headerField)
            }
            let encoding: ParameterEncoding = .Custom({
                (convertible, params) in
                let mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
                mutableRequest.HTTPBody = prmString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                return (mutableRequest, nil)
            })
            request = encoding.encode(mutableURLRequest, parameters: [:]).0
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
        return authRequestNotMappable(request, animated: animated)
    }
    
    // MARK: - Authenticated request with Auth access_token
    class func authenticatedRequestWithJsonNotMappable<T: JsonParsed>(urlString: String, params: [String: String]?, animated: Bool) -> Future<WebResult<T>, NSError> {
        return authenticatedRequestWithJsonNotMappable(urlString, params: params, paramsString: nil, animated: animated)
    }
    class func authenticatedRequestWithJsonNotMappable<T: JsonParsed>(urlString: String, params: [String: String]?, paramsString: String?, animated: Bool) -> Future<WebResult<T>, NSError> {
        print(urlString)
        var request: NSURLRequest!
        if let prmString = paramsString {
            let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
            mutableURLRequest.HTTPMethod = "POST"
            let headers = ["Accept":"application/json", "Content-Type":"application/json", "User-Agent": FBNet.UserAgent]
            for (headerField, headerValue) in headers {
                mutableURLRequest.setValue(headerValue, forHTTPHeaderField: headerField)
            }
            let encoding: ParameterEncoding = .Custom({
                (convertible, params) in
                let mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
                mutableRequest.HTTPBody = prmString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                return (mutableRequest, nil)
            })
            request = encoding.encode(mutableURLRequest, parameters: params).0
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
        return authRequestNotMappable(request, animated: animated)
    }
    class func authRequestNotMappable<T: JsonParsed>(request: NSURLRequest, animated: Bool) -> Future<WebResult<T>, NSError>  {
        let promise = Promise<WebResult<T>, NSError>()
        showBlocking(animated)
        AuthMe.getAuthenticatedRequest(request).onSuccess(callback: { (request) -> Void in
            let manager = Alamofire.Manager.sharedInstance
            manager.request(request).responseJSON { (response) -> Void in
                //print(response.request)  // original URL request
                //print(response.response) // URL response
                //print(response.data)     // server data
                //print(response.result)   // result of response serialization
                Async.background {
                    //let dataString = NSString(data: response.data!, encoding: NSUTF8StringEncoding)
                    //print(dataString)
                    mapResultNotMappable(response, promise: promise)
                    }.main{
                        closeBlocking(animated)
                }
            }
        }).onFailure(callback: { (error) -> Void in
            handleError(error)
            closeBlocking(animated)
            promise.failure(error)
        })
        return promise.future
    }
    
    // MARK: - This request not contains Auth parameters
    class func requestNotMappable<T: JsonParsed>(urlString: String, params: [String: String]?, animated: Bool) -> Future<WebResult<T>, NSError> {
        print(urlString)
        let promise = Promise<WebResult<T>, NSError>()
        showBlocking(animated)
        Alamofire.request(.POST, urlString, parameters: params, encoding: .URL, headers: ["User-Agent": FBNet.UserAgent]).responseJSON { (response) -> Void in
            Async.background {
                //let dataString = NSString(data: response.data!, encoding: NSUTF8StringEncoding)
                //print(dataString)
                mapResultNotMappable(response, promise: promise)
                }.main {
                    closeBlocking(animated)
            }
        }
        return promise.future
    }
    
    // MARK: - Request with params in url
    class func requestWithUrlParamsNotMappable<T: JsonParsed>(url: String, params: [String: String]?, animated: Bool) -> Future<WebResult<T>, NSError> {
        var urlString = url
        print(urlString)
        let promise = Promise<WebResult<T>, NSError>()
        if let parameters = params where parameters.count > 0 {
            urlString += "?"
            for (key, value) in parameters {
                urlString += key + "=" + value + "&"
            }
        }
        showBlocking(animated)
        Alamofire.request(.POST, urlString, parameters: nil, encoding: .URL, headers: ["User-Agent": FBNet.UserAgent]).responseJSON { (response) -> Void in
            Async.background {
                //let dataString = NSString(data: response.data!, encoding: NSUTF8StringEncoding)
                //print(dataString)
                mapResultNotMappable(response, promise: promise)
                }.main {
                    closeBlocking(animated)
            }
        }
        return promise.future
    }
    
    // MARK: - JSON sending request
    class func requestWithJsonNotMappable<T: JsonParsed>(urlString: String, params: [String: String]?, animated: Bool) -> Future<WebResult<T>, NSError> {
        print(urlString)
        let promise = Promise<WebResult<T>, NSError>()
        showBlocking(animated)
        jsonRequest(urlString, params: params) { (response) -> () in
            mapResultNotMappable(response, promise: promise)
            closeBlocking(animated)
        }
        return promise.future
    }
    
    // MARK: - mapping the results
    private class func mapResultNotMappable<T: JsonParsed>(response: Response<AnyObject, NSError>, promise: Promise<WebResult<T>, NSError>) {
        switch response.result {
        case .Success(let value):
            Async.background {
                let json = SwiftyJSON.JSON(value)
                do {
                    let resultObject = try T.instantiateFromJsonDictionary(json)
                    Async.main {
                        promise.success(WebResult(value: resultObject))
                    }
                } catch {
                    handleError(error)
                    Async.main {
                        promise.failure(NSError(domain: "UnableToConvertJsonParsed", code: -1, userInfo: nil))
                    }
                }
            }
        case .Failure(let error):
            handleError(error)
            promise.failure(error)
        }
    }
}