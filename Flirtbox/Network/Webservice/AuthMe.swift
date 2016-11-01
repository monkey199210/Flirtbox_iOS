//
//  AuthMe.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 20.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import Foundation
import Heimdallr
import MRProgress
import BrightFutures
import Alamofire

struct AuthConstants {
    static let clientId = "testclient"
    static let client_secret = "testpass"
}

class AuthMe {
    class func logout() {
        heimdallr.clearAccessToken()
        signUpHeimdallr.clearAccessToken()
        facebookSignUpHeimdallr.clearAccessToken()
        facebookLoginHeimdallr.clearAccessToken()
        UserProfile.clearCachedItems()
        LoadingImage.removeNeedToLoadImages()
        FBEvent.authenticated(false)
    }
    class func isAuthenticated() -> Bool {
        return heimdallr.hasAccessToken
    }
    private static var accessTokenStore = ProtectedOAuthAccessTokenKeychainStore()
    
    private static var heimdallr: Heimdallr {
        get{
            let credentials = OAuthClientCredentials(id: AuthConstants.clientId , secret: AuthConstants.client_secret)
            let tokenURL = NSURL.FBURL(FBNet.USER_NEW_TOKEN)
            return Heimdallr(tokenURL: tokenURL!, credentials: credentials, accessTokenStore: AuthMe.accessTokenStore)
        }
    }
    private static var signUpHeimdallr: Heimdallr {
        get{
            let signUpURL = NSURL.FBURL(FBNet.USER_SIGNUP)
            return Heimdallr(tokenURL: signUpURL!, credentials: nil, accessTokenStore: AuthMe.accessTokenStore, httpClient: AuthClient.sharedInstance)
        }
    }
    private static var facebookSignUpHeimdallr: Heimdallr {
        get{
            let signUpURL = NSURL.FBURL(FBNet.FACEBOOK_SIGNUP)
            return Heimdallr(tokenURL: signUpURL!, credentials: nil, accessTokenStore: AuthMe.accessTokenStore, httpClient: FacebookAuthClient.sharedInstance)
        }
    }
    private static var facebookLoginHeimdallr: Heimdallr {
        get{
            let signUpURL = NSURL.FBURL(FBNet.FACEBOOK_LOGIN)
            return Heimdallr(tokenURL: signUpURL!, credentials: nil, accessTokenStore: AuthMe.accessTokenStore, httpClient: FacebookLoginClient.sharedInstance)
        }
    }
    class func auth(username: String, password: String) -> Future<Bool, NSError> {
        return auth(username, password: password, animated: true)
    }
    class func auth(username: String, password: String, animated: Bool) -> Future<Bool, NSError> {
        let promise = Promise<Bool, NSError>()
        Webservice.showBlocking(animated)
        heimdallr.requestAccessToken(username: username, password: password) { result in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                switch result {
                case .Success(_):
                    FBEvent.authenticated(true)
                    promise.success(true)
                case .Failure(let error):
                    print(error)
                    promise.failure(error)
                }
                Webservice.closeBlocking(animated)
            })
        }
        return promise.future
    }
    class func signUp(username: String, sexuality: Sexuality, email: String, birthdate: NSDate, place: FBPlace?, coordinates: (latitude: Double, longitude: Double)) -> Future<Bool, NSError> {
        return signUp(username, sexuality: sexuality, email: email, birthdate: birthdate, place: place, coordinates: coordinates, animated: true)
    }
    class func signUp(username: String, sexuality: Sexuality, email: String, birthdate: NSDate, place: FBPlace?, coordinates: (latitude: Double, longitude: Double), animated: Bool) -> Future<Bool, NSError> {
        let promise = Promise<Bool, NSError>()
        Webservice.showBlocking(animated)
        //use empty values because this values will be replaced with AuthClient
        //AuthClient needed because Heimdallr library haven't sign up request and have private access token
        AuthClient.sharedInstance.params = ["username":username, "sexuality":String(sexuality.rawValue), "email": email, "dayOfBirth": String(birthdate.day()), "monthOfBirth": String(birthdate.month()), "yearOfBirth": String(birthdate.year()), "simCountryISO": FBoxHelper.getSimCountryISO(), "latitude": String(coordinates.latitude), "longitude": String(coordinates.longitude)]
        if let place = place {
            AuthClient.sharedInstance.params["location"] = place.location.id
            AuthClient.sharedInstance.params["town"] = place.location.town
            AuthClient.sharedInstance.params["country"] = place.location.country
        }
        signUpHeimdallr.requestAccessToken(username: "", password: "") { (result) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                switch result {
                case .Success(_):
                    FBEvent.authenticated(true)
                    promise.success(true)
                case .Failure(let error):
                    print(error)
                    promise.failure(error)
                }
                Webservice.closeBlocking(animated)
            })
        }
        return promise.future
    }
    class func facebookSignUp(facebook_token: String, username: String) -> Future<Bool, NSError> {
        let promise = Promise<Bool, NSError>()
        Webservice.showBlocking(true)
        FacebookAuthClient.sharedInstance.params = ["facebook_token": facebook_token, "username": username]
        facebookSignUpHeimdallr.requestAccessToken(username: "", password: "") { (result) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                switch result {
                case .Success(_):
                    FBEvent.authenticated(true)
                    promise.success(true)
                case .Failure(let error):
                    print(error)
                    promise.failure(error)
                }
                Webservice.closeBlocking(true)
            })
        }
        return promise.future
    }
    class func facebookLogin(facebook_token: String) -> Future<Bool, NSError> {
        let promise = Promise<Bool, NSError>()
        Webservice.showBlocking(true)
        FacebookLoginClient.sharedInstance.params = ["facebook_token": facebook_token]
        facebookLoginHeimdallr.requestAccessToken(username: "", password: "") { (result) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                switch result {
                case .Success(_):
                    FBEvent.authenticated(true)
                    promise.success(true)
                case .Failure(let error):
                    print(error)
                    promise.failure(error)
                }
                Webservice.closeBlocking(true)
            })
        }
        return promise.future
    }
    private static var isAuthenticating = false
    private static var waitingAuthRequests: [(Promise<NSURLRequest, NSError>, NSURLRequest)] = []
    class func getAuthenticatedRequest(inRequest: NSURLRequest) -> Future<NSURLRequest, NSError> {
        let promise = Promise<NSURLRequest, NSError>()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if !isAuthenticating {
                isAuthenticating = true
                heimdallr.authenticateRequest(inRequest, completion: { (result) -> () in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        switch result {
                        case .Success(let request):
                            promise.success(request)
                        case .Failure(let error):
                            print(error)
                            self.logout()
                            promise.failure(error)
                        }
                        isAuthenticating = false
                        self.checkWaitingAuthRequests()
                    })
                })
            }else{
                waitingAuthRequests.append((promise, inRequest))
            }
        })
        return promise.future
    }
    private class func checkWaitingAuthRequests() {
        if !isAuthenticating && waitingAuthRequests.count > 0 {
            let first = waitingAuthRequests.removeAtIndex(0)
            let promise = first.0
            let inRequest = first.1
            isAuthenticating = true
            heimdallr.authenticateRequest(inRequest, completion: { (result) -> () in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    switch result {
                    case .Success(let request):
                        promise.success(request)
                    case .Failure(let error):
                        print(error)
                        self.logout()
                        promise.failure(error)
                    }
                })
                isAuthenticating = false
                self.checkWaitingAuthRequests()
            })
        }
    }
}