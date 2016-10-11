//
//  APIClient+Activities.swift
//  Vasctrac
//
//  Created by Developer on 5/4/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import SwiftyJSON

extension APIClient {

    func sendMedicalHistorySurvey(dataHistory: [String: AnyObject]?, dataMedication: [String: AnyObject]?,
                                  completionHandler: (String? -> Void)) {
        
        /* BODY
         {
         "pad":false,
         "smoking":true,
         "diabetes":false,
         "hypertension":true,
         "heart_disease":false,
         }
         */
        
        if dataHistory?.count > 0 {
            self.makeRequestWithErrorHandling(.PUT, .MedicalHistory(userId), parameters: dataHistory) { response, error in
                print("MedicalHistorySurvey History sent: \(response)")
            }
        }
        
        if dataMedication?.count > 0 {
            self.makeRequestWithErrorHandling(.PUT, .Medication(userId), parameters: dataMedication) { response, error in
                print("MedicalHistorySurvey Medication sent: \(response)")
            }
        }
        
    }
    
    func sendSurgicalHistory(surgeries: [[String: String]], completionHandler: (String? -> Void)) {
        
        /* response:
         {
         "id":1,
         "surgery_type":"Openvascular",,
         "surgery_location":"Left Tibials",
         "surgery_date":"1992-01-01T01:01:11.000Z",
         }
         */
        
        for surgery in surgeries {
            self.makeRequestWithErrorHandling(.POST, .Surgeries(userId), parameters: surgery) { response, error in
                print("Surgery sent\(response)")
            }
        }
    }
    
    func sendPhysicalActivitySurvey(data: [String : AnyObject]) {
        
        self.makeRequestWithErrorHandling(.PUT, .PhysicalActivity(userId), parameters: data) { response, error in
            print("physical Activity sent\(response)")
        }
        
    }
    
    // MARK: - Walk Data, Steps Data
    
    func allWalkTests(onCompletion:(([String : AnyObject]?, String?) -> Void)) {
        
        self.makeRequestWithErrorHandling(.GET, .WalkTest(userId)) { response, error in
            guard error == nil else {
                onCompletion(nil, error)
                return
            }
            
            if let response = response {
                onCompletion(JSON(response).dictionaryObject, nil)
            }
        }
    }
    
    func latestWalkTest(onCompletion: (([String : AnyObject]?, String?) -> Void)) {
        
        let parameters = [
            "latest" : "true"
        ]
        
        self.makeRequestWithErrorHandling(.GET, .WalkTest(userId), parameters: parameters, encoding: .URLEncodedInURL) { response, error in
            guard error == nil else {
                onCompletion(nil, error)
                return
            }
            
            if let response = response {
                let json = JSON(response).arrayObject
                if let value = json?.first {
                    onCompletion(JSON(value).dictionaryObject, nil)
                }
            }
        }
    }
    
    func sendWalkTest(parameters: [String : AnyObject], onCompletion: (([String : AnyObject]?, String?) -> Void)) {
        
        self.makeRequestWithErrorHandling(.POST, .WalkTest(userId), parameters: parameters) { response, error in
            guard error == nil else {
                onCompletion(nil, error)
                return
            }
            
            if let response = response {
                onCompletion(JSON(response).dictionaryObject, nil)
            }
        }
    }
    
    func updateDailyData(dataId: String, data: [String: AnyObject], onCompletion: (([String:AnyObject]?, String?) -> Void)?) {
        
        self.makeRequestWithErrorHandling(.PUT, .UpdateDailySteps(userId,dataId), parameters: data) { response, error in
            if let response = response {
                onCompletion?(JSON(response).dictionaryObject, nil)
            }
        }
    }
    
    func sendDailyData(data: [String: AnyObject], onCompletion: (([AnyObject]?, String?) -> Void)) {
        
        self.makeRequestWithErrorHandling(.POST, .DailySteps(userId), parameters: data) { response, error in
            guard error == nil else {
                onCompletion(nil, error)
                return
            }
            
            if let response = response {
                let json = JSON(response)
                
                if let daysData = json["daysData"].arrayObject {
                    onCompletion(daysData,error)
                }
            }
        }
    }

}
