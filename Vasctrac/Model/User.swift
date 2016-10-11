//
//  User.swift
//  Vasctrac
//
//  Created by Developer on 3/13/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import Foundation
import RealmSwift

enum Gender: Int {
    case Male = 0
    case Female
    
    var stringValue : String {
        switch self {
        case .Male:
            return "Male"
        case .Female:
            return "Female"
        }
    }
    
    static let all = [Male, Female]
}

class User: Object {
    
    /* from server:
    {
    "first_name" : "John",
    "last_name" : "Doe",
    "gender" : 0,
    "abi" : 1.2,
    "informed_consent" : true,
    "height" : 72,
    "weight" : 150,
    "email" : "johndoe@example.com",
    "ethnicity_id" : 2,
    "date_of_birth" : "1990-01-01T01:01:11.000Z"
    }
    */
    
    dynamic var userId: String!
    dynamic var first_name: String = ""
    dynamic var last_name: String = ""
    private(set) dynamic var fullName: String = "" // stored locally only
    dynamic var email: String = ""
    private(set) dynamic var picture: NSData? = nil // stored locally only 
    private dynamic var gender: Int  = 0
    dynamic var date_of_birth: String = ""
    dynamic var informed_consent: Bool = false
    private dynamic var height: Double = 0 // in inches
    dynamic var weight: Double = 0
    
    private(set) dynamic var lastDateStepsDataSent : NSDate? = nil // stored locally only
    private(set) dynamic var dailyDataLastSentId : String? = nil
    
    dynamic var lastWalkTestResult : WalkTestResult? = nil
    
    var messages : List<Message>? = nil
    
    override static func primaryKey() -> String? {
        return "userId"
    }
    
    func dailyDataSent(withDate lastDate: NSDate, andDataId dataId: String) {
        let realm = try! Realm()
        try! realm.write {
            self.lastDateStepsDataSent = lastDate
            self.dailyDataLastSentId = dataId
        }
    }
    
    func profilePicture(picture: NSData?) {
        let realm = try! Realm()
        try! realm.write {
            self.picture = picture
        }
    }
    
    func fullName(name: String) {
        let realm = try! Realm()
        try! realm.write {
            self.fullName = name
        }
    }
    
    func changeEmail(email: String) {
        let realm = try! Realm()
        try! realm.write {
            self.email = email
        }
    }
    
    func stringGender() -> String {
        return Gender.all[self.gender].stringValue
    }
    
    func heightInFeets() -> String {
        // ft = in / 12.00000
        let heightInFeets = self.height/12
        let feets = Int(heightInFeets)
        let inches = Int(ceil((heightInFeets - Double(feets))*10))
        return "\(feets)'\(inches)''"
    }
}
