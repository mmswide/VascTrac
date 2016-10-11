//
//  APIClient+Surveys.swift
//  Vasctrac
//
//  Created by Developer on 5/4/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

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
    
    func sendWalkActivity(walkData: [String : AnyObject], completionHandler: (String? -> Void)) {
        
        self.makeRequestWithErrorHandling(.POST, .WalkActivity(userId), parameters: walkData) { response, error in
            print("Walk data sent\(response)")
        }
    }
    
    func sendDailyData(data: [String: AnyObject], onCompletion:(Bool -> Void)) {
        
        self.makeRequestWithErrorHandling(.POST, .DailySteps(userId), parameters: data) { response, error in
            guard error == nil else {
                onCompletion(false)
                return
            }
            onCompletion(true)
        }
    }

}
