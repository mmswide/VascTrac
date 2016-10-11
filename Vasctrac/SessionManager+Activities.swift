//
//  SessionManager+Activities.swift
//  Vasctrac
//
//  Created by Developer on 5/19/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import SwiftyJSON

extension SessionManager {
    
    func sendWalkTestResult(parameters: [String : AnyObject], onCompletion:(WalkTestResult? -> Void)) {
        
        APIClient.sharedClient.sendWalkTest(parameters) { response, error in
            if let response = response {
                self.createLastWalkTestResult(withDict: response)
                onCompletion(self.currentUser?.lastWalkTestResult)
            }
        }
    }
    
    func userLastWalkTestResult(onCompletion:(WalkTestResult? -> Void)) {
        
        if let lastWalkTestResult = self.currentUser?.lastWalkTestResult {
            onCompletion(lastWalkTestResult)
        } else {
            APIClient.sharedClient.latestWalkTest() { response, error in
                guard error == nil else {
                    onCompletion(nil)
                    return
                }
                
                if let response = response {
                    let json = JSON(response)
                    
                    if let recentTestResult = json.dictionaryObject {
                        self.createLastWalkTestResult(withDict: recentTestResult)
                        onCompletion(self.currentUser?.lastWalkTestResult)
                    }
                }
            }
        }
    }
    
    private func createLastWalkTestResult(withDict dict: [String:AnyObject]) {
        
        let json = JSON(dict)
        var walkTestResultDict = json.dictionaryObject!
        walkTestResultDict["id"] = json["id"].numberValue.stringValue
        
        try! self.realm.write {
            self.currentUser?.lastWalkTestResult = WalkTestResult(value: walkTestResultDict)
        }
    }
    
}
