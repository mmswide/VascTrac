//
//  Message.swift
//  Vasctrac
//
//  Created by Developer on 6/29/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import RealmSwift
import ObjectMapper

enum MessageType : String {
    case WalkTest = "walking"
    case QuarterlySurvey = "quarterly"
}

class Message: Object, Mappable {
    
    /*
        {
        id = 56;
        name = "Quarterly Survey Needs to be conducted.";
        type = quarterly;
        }
    */
    
    dynamic var id : Int = 0
    dynamic var name: String!
    private dynamic var typeString: String!
    var type : MessageType {
        switch MessageType(rawValue: self.typeString)! {
        case .WalkTest:
            return .WalkTest
        case .QuarterlySurvey:
            return .QuarterlySurvey
        }
    }
    
    var title : String {
        switch self.type {
        case .WalkTest:
            return NSLocalizedString("Walk Test", comment: "")
            
        case .QuarterlySurvey:
            return NSLocalizedString("Quarterly Survey", comment: "")
        }
    }
    
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        typeString <- map["type"]
    }
    

    
}

