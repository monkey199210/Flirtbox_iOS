//
//  FacebookLoginClient.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 30.12.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit
import Heimdallr
import Alamofire

class FacebookLoginClient: HeimdallrHTTPClient {
    //replace client because Heimdallr library don't have sign up methods
    @objc func sendRequest(request: NSURLRequest, completion: (data: NSData?, response: NSURLResponse?, error: NSError?) -> ()) {
        var urlString = String.FBURL(FBNet.FACEBOOK_LOGIN)
        let parameters = self.params
        if parameters.count > 0 {
            urlString += "?"
            for (key, value) in parameters {
                urlString += key + "=" + String(value) + "&"
            }
        }
        Alamofire.request(.POST, urlString, parameters: nil, encoding: .URL, headers: ["User-Agent": FBNet.UserAgent]).responseJSON { (response) -> Void in
            switch response.result {
            case .Success(_):
                let dataString = NSString(data: response.data!, encoding: NSUTF8StringEncoding)
                print(dataString)
                completion(data: response.data, response: response.response, error: nil)
            case .Failure(let error):
                completion(data: response.data, response: response.response, error: error)
            }
        }
    }
    
    // MARK: Shared Instance
    static let sharedInstance = FacebookLoginClient()
    var params: [String: String] = [:]
}
