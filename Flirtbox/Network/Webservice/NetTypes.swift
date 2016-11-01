//
//  NetClasses.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 23.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import Foundation
import Genome

struct FBUser : BasicMappable {
    struct UserGeneral : BasicMappable {
        private(set) var username: String = ""
        private(set) var gender: String?
        private(set) var age: String?
        private(set) var dateOfBirth: String?
        private(set) var sexuality: String?
        private(set) var starsign: String?
        private(set) var country: String = ""
        private(set) var town: String?
        private(set) var originalCountry: String = ""
        private(set) var description: String = ""
        private(set) var email: FBEmail!
        private(set) var phone: FBPhone!
        private(set) var registrationIds: Array<String>?
        mutating func sequence(map: Map) throws {
            try username <~ map["username"]
            try gender <~ map["gender"]
            try age <~ map["age"]
            try dateOfBirth <~ map["dateOfBirth"]
            try sexuality <~ map["sexuality"]
            try starsign <~ map["starsign"]
            try country <~ map["country"]
            try town <~ map["town"]
            try originalCountry <~ map["originalCountry"]
            try description <~ map["description"]
            try email <~ map["email"]
            try phone <~ map["phone"]
            try registrationIds <~ map["registrationIds"]
        }
    }
    private(set) var general: UserGeneral!
    
    struct UserAppearance : BasicMappable {
        private(set) var height: String = ""
        private(set) var eyecolour: String = ""
        private(set) var haircolour: String = ""
        private(set) var hairstyle: String = ""
        private(set) var ethnic: String = ""
        private(set) var bodyshape: String = ""
        mutating func sequence(map: Map) throws {
            try height <~ map["height"]
            try eyecolour <~ map["eyecolour"]
            try haircolour <~ map["haircolour"]
            try hairstyle <~ map["hairstyle"]
            try ethnic <~ map["ethnic"]
            try bodyshape <~ map["bodyshape"]
        }
    }
    private(set) var appearance: UserAppearance!
    
    struct UserLife : BasicMappable {
        private(set) var occupation: String = ""
        private(set) var education: String = ""
        private(set) var profession: String = ""
        mutating func sequence(map: Map) throws {
            try occupation <~ map["occupation"]
            try education <~ map["education"]
            try profession <~ map["profession"]
        }
    }
    private(set) var life: UserLife!
    
    struct UserQanda : BasicMappable {
        private(set) var aboutMe: Array<UserQuestion>?
        private(set) var stuffILike: Array<UserQuestion>?
        private(set) var myAttitude: Array<UserQuestion>?
        mutating func sequence(map: Map) throws {
            try aboutMe <~ map["about me"]
            try stuffILike <~ map["stuff i like"]
            try myAttitude <~ map["my attitude"]
        }
    }
    private(set) var qanda: UserQanda!
    
    private(set) var favourites: Dictionary<String,Array<String>>?
    
    struct UserConnections : BasicMappable {
		var isFavourite: Bool = false
        var isBlocked: Bool = false
        private(set) var wantToMeet: Bool = false
        private(set) var contactPossible: Bool?
        private(set) var profileVisible: Bool?
        private(set) var requiresPhoto: Bool?
        private(set) var disableSharing: Bool?
        mutating func sequence(map: Map) throws {
            try isFavourite <~ map["isFavourite"]
            try isBlocked <~ map["isBlocked"]
            try wantToMeet <~ map["wantToMeet"]
            try contactPossible <~ map["contactPossible"]
            try profileVisible <~ map["profileVisible"]
            try requiresPhoto <~ map["requiresPhoto"]
            try disableSharing <~ map["disableSharing"]
        }
    }
	var connections: UserConnections?
    
    private(set) var pictures: Array<FBPicture>?
    private(set) var premium: Bool = false
    mutating func sequence(map: Map) throws {
        try general <~ map["general"]
        try appearance <~ map["appearance"]
        try life <~ map["life"]
        try qanda <~ map["qanda"]
        try favourites <~ map["favourites"]
        try connections <~ map["connections"]
        try pictures <~ map["pictures"]
//        try premium <~ map["premium"]
    }
}
struct AuthResponce : BasicMappable {
    private(set) var access_token: String?
    private(set) var expires_in: Int?
    private(set) var token_type: String?
    private(set) var refresh_token: String?
    private(set) var error: String?
    private(set) var error_description: String?
    mutating func sequence(map: Map) throws {
        try access_token <~ map["access_token"]
        try expires_in <~ map["expires_in"]
        try token_type <~ map["token_type"]
        try refresh_token <~ map["refresh_token"]
        try error <~ map["error"]
        try error_description <~ map["error_description"]
    }
}
struct UserQuestion : BasicMappable {
    private(set) var id: String = ""
    private(set) var title: String = ""
    private(set) var answer: String = ""
    mutating func sequence(map: Map) throws {
        try id <~ map["id"]
        try title <~ map["title"]
        try answer <~ map["answer"]
    }
}
struct FBResponce : BasicMappable {
    private(set) var status: Int?
    private(set) var errorCode: AnyObject?
    private(set) var errorDescription: String?
    private(set) var message: String?
    mutating func sequence(map: Map) throws {
        try status <~ map["status"]
        try errorCode <~ map["errorCode"]
        try errorDescription <~ map["errorDescription"]
        try message <~ map["message"]
    }
}
struct FBResult : BasicMappable {
    private(set) var status: Int = 0
    private(set) var message: String = ""
    mutating func sequence(map: Map) throws {
        try status <~ map["status"]
        try message <~ map["message"]
    }
}

struct FBValid : BasicMappable {
    private(set) var valid: Bool = false
    mutating func sequence(map: Map) throws {
        try valid <~ map["valid"]
    }
}
struct FBLocation : BasicMappable {
    private(set) var id: String = ""
    private(set) var region: String = ""
    private(set) var town: String = ""
    private(set) var country: String = ""
    mutating func sequence(map: Map) throws {
        try id <~ map["id"]
        try region <~ map["region"]
        try town <~ map["town"]
        try country <~ map["country"]
    }
}
struct FBPlace : BasicMappable {
    private(set) var geoname: String = ""
    private(set) var location: FBLocation!
    mutating func sequence(map: Map) throws {
        try geoname <~ map["geoname"]
        try location <~ map["location"]
    }
}
struct FBMessage : BasicMappable {
    private(set) var uid: String = ""
    private(set) var username: String = ""
    private(set) var subject: String?
    private(set) var lastMessage: String?
    private(set) var receivedAt: String = ""
    private(set) var avatar: String?
    var unreadMessages: AnyObject? = 0
    mutating func sequence(map: Map) throws {
        try uid <~ map["uid"]
        try username <~ map["username"]
        try subject <~ map["subject"]
        try lastMessage <~ map["lastMessage"]
        try receivedAt <~ map["receivedAt"]
        try avatar <~ map["avatar"]
        try unreadMessages <~ map["unreadMessages"]
    }
}
struct FBArchivedMessage : BasicMappable {
    private(set) var id: String = ""
    private(set) var body: String = ""
    private(set) var fromId: String = ""
    private(set) var toId: String = ""
    private(set) var when: String = ""
    private(set) var read: String = ""
    private(set) var avatar: String = ""
    mutating func sequence(map: Map) throws {
        try id <~ map["id"]
        try body <~ map["body"]
        try fromId <~ map["fromId"]
        try toId <~ map["toId"]
        try when <~ map["when"]
        try read <~ map["read"]
        try avatar <~ map["avatar"]
    }
}
struct FBConversation : BasicMappable {
    private(set) var id: String = ""
    private(set) var body: String = ""
    private(set) var fromUsername: String = ""
    private(set) var fromGender: String = ""
    private(set) var toUsername: String = ""
    private(set) var toGender: String = ""
    private(set) var when: String = ""
    private(set) var read: String = ""
    mutating func sequence(map: Map) throws {
        try id <~ map["id"]
        try body <~ map["body"]
        try fromUsername <~ map["fromUsername"]
        try fromGender <~ map["fromGender"]
        try toUsername <~ map["toUsername"]
        try toGender <~ map["toGender"]
        try when <~ map["when"]
        try read <~ map["read"]
    }
}
struct FBPicture : BasicMappable {
    private(set) var picid: String = ""
    private(set) var cryptedname: String = ""
    private(set) var description: String = ""
    private(set) var mainpic: String = ""
    private(set) var approvedwhen: String = ""
    private(set) var uploadwhen: String = ""
    private(set) var level: String = ""
    private(set) var orderid: String = ""
    var visibility: String = ""
    var ratable: String = ""
    private(set) var averageVote: String = ""
    private(set) var totalVotes: String = ""
    mutating func sequence(map: Map) throws {
        try picid <~ map["picid"]
        try cryptedname <~ map["cryptedname"]
        try description <~ map["description"]
        try mainpic <~ map["mainpic"]
        try approvedwhen <~ map["approvedwhen"]
        try uploadwhen <~ map["uploadwhen"]
        try level <~ map["level"]
        try orderid <~ map["orderid"]
        try visibility <~ map["visibility"]
        try ratable <~ map["ratable"]
        try averageVote <~ map["averageVote"]
        try totalVotes <~ map["totalVotes"]
    }
    
    // MARK: - Public
    func getUrl() -> String {
        return FBNet.PROFILE_PIC_HIGH_RES + self.cryptedname
    }
}
struct FBSearchedUser : BasicMappable {
    private(set) var username: String = ""
    private(set) var gender: String = ""
    private(set) var age: AnyObject = 0
    private(set) var countryId: String = ""
    private(set) var country: String? = ""
    private(set) var avatar: String?
    private(set) var town: String = ""
    private(set) var latitude: AnyObject?
    private(set) var longitude: AnyObject?
    private(set) var regdateTime: String?
    private(set) var visitTime: String?
    mutating func sequence(map: Map) throws {
        try username <~ map["username"]
        try gender <~ map["gender"]
        try age <~ map["age"]
        try countryId <~ map["countryId"]
        try country <~ map["country"]
        try avatar <~ map["avatar"]
        try town <~ map["town"]
        try latitude <~ map["latitude"]
        try longitude <~ map["longitude"]
        try regdateTime <~ map["regdateTime"]
        try visitTime <~ map["visitTime"]
    }
}
struct FBSexyOrNotUser : BasicMappable {
    private(set) var uid: Int = 0
    private(set) var picid: Int = 0
    private(set) var averageVote: Float = 5.0
    private(set) var uname: String = ""
    private(set) var cryptedname: String?
	private(set) var age: Int = 0
    mutating func sequence(map: Map) throws {
        try uid <~ map["uid"]
        try picid <~ map["picid"]
        try averageVote <~ map["averageVote"]
        try uname <~ map["uname"]
        try cryptedname <~ map["cryptedname"]
		try age <~ map["age"]
    }
}
struct FBLightUser : BasicMappable {
    private(set) var id: String = ""
    private(set) var uid: String = ""
    private(set) var age: String = ""
    private(set) var gender: String = ""
    private(set) var avatar: String = ""
    private(set) var town: String = ""
    mutating func sequence(map: Map) throws {
        try id <~ map["id"]
        try uid <~ map["uid"]
        try age <~ map["age"]
        try gender <~ map["gender"]
        try avatar <~ map["avatar"]
        try town <~ map["town"]
    }
}
struct FBQuestion : BasicMappable {
    private(set) var id: String = ""
    private(set) var title: String = ""
    private(set) var example: String = ""
    mutating func sequence(map: Map) throws {
        try id <~ map["id"]
        try title <~ map["title"]
        try example <~ map["example"]
    }
}
struct FBMetaResult : BasicMappable {
    private(set) var appearance: AnyObject = ""
    mutating func sequence(map: Map) throws {
        try appearance <~ map["MY APPEARANCE"]
    }
}
struct FBLocalValue : BasicMappable {
    private(set) var id: String?
    private(set) var text: String = ""
    private(set) var value: String?
    mutating func sequence(map: Map) throws {
        try id <~ map["id"]
        try text <~ map["text"]
        try value <~ map["value"]
    }
}
struct FBFeedbackCategory : BasicMappable {
    private(set) var categoryID: String = ""
    private(set) var category: String = ""
    mutating func sequence(map: Map) throws {
        try categoryID <~ map["categoryID"]
        try category <~ map["category"]
    }
}
struct FBVisibilityOption : BasicMappable {
    private(set) var id: String = ""
    private(set) var name: String = ""
    mutating func sequence(map: Map) throws {
        try id <~ map["id"]
        try name <~ map["name"]
    }
}
struct FBSettingsValue : BasicMappable {
    private(set) var id: String = ""
    private(set) var name: String = ""
    private(set) var active: Bool = false
    mutating func sequence(map: Map) throws {
        try id <~ map["id"]
        try name <~ map["name"]
        try active <~ map["active"]
    }
}
struct FBEmail : BasicMappable {
    private(set) var email: String?
    private(set) var code: String?
    private(set) var confirmed: AnyObject?
    mutating func sequence(map: Map) throws {
        try email <~ map["email"]
        try code <~ map["code"]
        try confirmed <~ map["confirmed"]
    }
}
struct FBPhone : BasicMappable {
    private(set) var phone: String?
    private(set) var code: String?
    private(set) var confirmed: AnyObject?
    mutating func sequence(map: Map) throws {
        try phone <~ map["phone"]
        try code <~ map["code"]
        try confirmed <~ map["confirmed"]
    }
}