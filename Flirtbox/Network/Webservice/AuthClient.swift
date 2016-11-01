//
//  AuthClient.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 24.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit
import Heimdallr

class AuthClient: HeimdallrHTTPClient {
    //replace client because Heimdallr library don't have sign up methods
    @objc func sendRequest(request: NSURLRequest, completion: (data: NSData?, response: NSURLResponse?, error: NSError?) -> ()) {
        let urlString = String.FBURL(FBNet.USER_SIGNUP)
        Webservice.jsonRequest(urlString, params: self.params) { (response) -> () in
            switch response.result {
            case .Success(_):
                completion(data: response.data, response: response.response, error: nil)
            case .Failure(let error):
                completion(data: response.data, response: response.response, error: error)
            }
        }
    }
    
    // MARK: Shared Instance
    static let sharedInstance = AuthClient()
    var params: [String: String] = [:]
}
