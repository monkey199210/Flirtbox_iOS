//
//  ImageUploader.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 28.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import Foundation
import Alamofire
import BrightFutures

//Alamofire can't send image. Don't know reason.
extension NSMutableData {
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}
class UploadTaskDelegate : NSObject, NSURLSessionTaskDelegate {
    var progressCallbacks: [NSURLSession:(Double->Void)] = [:]
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        if let callback = self.progressCallbacks[session] {
            callback(Double(totalBytesSent)/Double(totalBytesExpectedToSend))
        }
    }
}
class ImageUploader {
    static var uploadTaskDelegate = UploadTaskDelegate()
    class func uploadImage(uploadUrl: String, imageData: NSData, progressCallback: (Double->Void)?) -> Future<Bool, NSError> {
        let promise = Promise<Bool, NSError>()
        let myUrl = NSURL(string: uploadUrl)
        let request = NSMutableURLRequest(URL:myUrl!)
        request.HTTPMethod = "POST";
        AuthMe.getAuthenticatedRequest(request).onSuccess(callback: { (authRequest) -> Void in
            let request = authRequest.mutableCopy() as! NSMutableURLRequest
            let boundary = generateBoundaryString()
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = createBodyWithParameters(nil, filePathKey: "userfile", imageDataKey: imageData, boundary: boundary)
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: ImageUploader.uploadTaskDelegate, delegateQueue: nil)
            ImageUploader.uploadTaskDelegate.progressCallbacks[session] = progressCallback
            let task = session.dataTaskWithRequest(request) {
                data, response, error in
                if error != nil {
                    print("error=\(error)")
                    promise.failure(error!)
                }else{
                    // You can print out response object
                    print("******* response = \(response)")
                    // Print out reponse body
                    let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("****** response data = \(responseString!)")
                    promise.success(true)
                }
                ImageUploader.uploadTaskDelegate.progressCallbacks[session] = nil
            }
            task.resume()
        }).onFailure(callback: { (error) -> Void in
            Webservice.handleError(error)
            promise.failure(error)
        })
        return promise.future
    }
    private class func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        let filename = "user-profile.jpeg"
        let mimetype = "image/jpeg"
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.appendData(imageDataKey)
        body.appendString("\r\n")
        body.appendString("--\(boundary)--\r\n")
        return body
    }
    private class func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
}