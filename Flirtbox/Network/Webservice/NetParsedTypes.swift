//
//  NetParsedTypes.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 26.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import Foundation
import SwiftyJSON

extension JsonParsed {
    static func instantiateFromJsonDictionary(json: SwiftyJSON.JSON) throws -> Self {
        let questions = Self()
        if let dict = json.dictionaryObject {
            for (key,subJson):(String, AnyObject) in dict {
                do {
                    try questions.fillFromDictionary(key, subJson: subJson)
                } catch {
                    throw ConvertingError.UnableToConvertJsonParsed
                }
            }
        }else{
            throw ConvertingError.UnableToConvertJsonParsed
        }
        return questions
    }
}
protocol JsonParsed {
    init()
    func fillFromDictionary(key: String, subJson: AnyObject) throws
}
class FBQuestions: JsonParsed {
    required init(){
        values = [:]
    }
    var values: [String:Array<FBQuestion>]!
    func fillFromDictionary(key: String, subJson: AnyObject) throws {
        do {
            if let array = subJson as? NSArray {
                var resultArray: Array<FBQuestion> = []
                for arrayValue in array {
                    let json = try Webservice.toJson(arrayValue)
                    let resultObject = try FBQuestion.mappedInstance(json)
                    resultArray.append(resultObject)
                }
                self.values[key] = resultArray
            }else{
                let genomeJson = try Webservice.toJson(subJson)
                let resultObject = try FBQuestion.mappedInstance(genomeJson)
                self.values[key] = [resultObject]
            }
        } catch {
            throw ConvertingError.UnableToConvertJsonParsed
        }
    }
}
class FBGroupWithRange: JsonParsed {
    required init(){
        group = 0
        age = []
    }
    var group: Int
    var age: Array<Int>
    func fillFromDictionary(key: String, subJson: AnyObject) throws {
        switch key {
        case "group":
            if let groupValue = subJson as? Int {
                group = groupValue
            }
        case "age":
            if let ageArray = subJson as? Array<Int> {
                age = ageArray
            }
        default:
            break;
        }
    }
}
class FBSettings: JsonParsed {
    required init(){
        settings = []
        notifications = []
        email = []
        phone = []
    }
    var settings: Array<FBSettingsValue>!
    var notifications: Array<FBSettingsValue>!
    var email: Array<FBEmail>!
    var phone: Array<FBPhone>!
    var visibility: FBGroupWithRange? = nil
    var contact: FBGroupWithRange? = nil
    func fillFromDictionary(key: String, subJson: AnyObject) throws {
        do {
            switch key {
            case "settings", "notifications":
                if let array = subJson as? NSArray {
                    var resultArray: Array<FBSettingsValue> = []
                    for arrayValue in array {
                        let json = try Webservice.toJson(arrayValue)
                        let resultObject = try FBSettingsValue.mappedInstance(json)
                        resultArray.append(resultObject)
                    }
                    if key == "settings" {
                        self.settings = resultArray
                    }else{
                        self.notifications = resultArray
                    }
                }else{
                    let genomeJson = try Webservice.toJson(subJson)
                    let resultObject = try FBSettingsValue.mappedInstance(genomeJson)
                    if key == "settings" {
                        self.settings = [resultObject]
                    }else{
                        self.notifications = [resultObject]
                    }
                }
            case "email":
                if let array = subJson as? NSArray {
                    var resultArray: Array<FBEmail> = []
                    for arrayValue in array {
                        let json = try Webservice.toJson(arrayValue)
                        let resultObject = try FBEmail.mappedInstance(json)
                        resultArray.append(resultObject)
                    }
                    self.email = resultArray
                }else{
                    let genomeJson = try Webservice.toJson(subJson)
                    let resultObject = try FBEmail.mappedInstance(genomeJson)
                    self.email = [resultObject]
                }
            case "phone":
                if let array = subJson as? NSArray {
                    var resultArray: Array<FBPhone> = []
                    for arrayValue in array {
                        let json = try Webservice.toJson(arrayValue)
                        let resultObject = try FBPhone.mappedInstance(json)
                        resultArray.append(resultObject)
                    }
                    self.phone = resultArray
                }else{
                    let genomeJson = try Webservice.toJson(subJson)
                    let resultObject = try FBPhone.mappedInstance(genomeJson)
                    self.phone = [resultObject]
                }
            case "visibility":
                let json = SwiftyJSON.JSON(subJson)
                visibility = try FBGroupWithRange.instantiateFromJsonDictionary(json)
            case "contact":
                let json = SwiftyJSON.JSON(subJson)
                contact = try FBGroupWithRange.instantiateFromJsonDictionary(json)
            default:
                break;
            }
        } catch {
            throw ConvertingError.UnableToConvertJsonParsed
        }
    }
}