//
//  DataCollector.swift
//  Vasctrac
//
//  Created by Developer on 3/18/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import ResearchKit
import SwiftyJSON

class DataCollector {

    // returns the user name
    class func collectContentData(taskResult: ORKTaskResult) -> (String?,String?) {
        
        var userFirstName : String? = nil
        var userLastName : String? = nil
        if let results = taskResult.results as? [ORKStepResult] {
            for stepResult: ORKStepResult in results {
                for result: ORKResult in stepResult.results! {
                    if let signatureResult = result as? ORKConsentSignatureResult {
                        userFirstName = signatureResult.signature?.givenName
                        userLastName = signatureResult.signature?.familyName
                        return (userFirstName, userLastName)
                    }
                }
            }
        }
        return (userFirstName, userLastName)
    }
        
    class func medicalHistoryCollectorHandler(taskResult: ORKTaskResult) -> ([String : AnyObject], [String : AnyObject]) {
        
        /* server:
        {
        "smoking": true,
        "hypertension": true, 
        "diabetes": true, 
        "pad": false, 
        "other": “other history", // String
        "heart_disease": false, 
        "none": false
        }
        
        {
        "warfarin": false,
        "other": “other medication",  // String
        "plavix": true, 
        "aspirin": true, 
        "statins": true, 
        "none": false
        }
        */
        
        var medicalHistoryDictionary = [String : AnyObject]()
        var medicationDictionary = [String : AnyObject]()
        if let results = taskResult.results as? [ORKStepResult] {
            
            for stepResult: ORKStepResult in results {
                
                for result: ORKResult in stepResult.results! {
                    
                    if let questionResult = result as? ORKChoiceQuestionResult {
                        
                        switch ActivitiesListRow.MedicalHistoryIdentifier(rawValue: questionResult.identifier)! {
                        case .HistoryChoices:
                            if let choices = questionResult.choiceAnswers {
                                let boolDictionary = DataCollector.parseToBooleanDictionary(choices as! [String], keys: ActivitiesListRow.MedicalHistoryIdentifier.historyChoicesValues)
                                
                                medicalHistoryDictionary.append(boolDictionary)
                            }
                        case .MedicationChoices:
                            if let choices = questionResult.choiceAnswers {
                                let boolDictionary = DataCollector.parseToBooleanDictionary(choices as! [String], keys: ActivitiesListRow.MedicalHistoryIdentifier.medicationChoicesValues)
                                
                                medicationDictionary.append(boolDictionary)
                            }
                        case .Smoking:
                            if let choices = questionResult.choiceAnswers {
                                medicalHistoryDictionary[questionResult.identifier] = choices.first as! String
                            }
                        default: break
                        }
                
                    } else if let questionResult = result as? ORKBooleanQuestionResult {
                        let questionId = questionResult.identifier
                        if let answer = questionResult.booleanAnswer {
                            if questionId == ActivitiesListRow.MedicalHistoryIdentifier.Pad.rawValue {
                                medicalHistoryDictionary[questionId] = answer
                            }
                        }
                    }
                }
            }
        }
        
        print(medicalHistoryDictionary)
        print(medicationDictionary)
        return (medicalHistoryDictionary, medicationDictionary)
    }
    
    class func surgicalHistoryIntroCollectorHandler(taskResult: ORKTaskResult) -> Bool {
        if let results = taskResult.results as? [ORKStepResult] {
            for stepResult: ORKStepResult in results {
                for result: ORKResult in stepResult.results! {
                    if let questionResult = result as? ORKBooleanQuestionResult,
                    let answer = questionResult.booleanAnswer {
                        return answer.boolValue
                    }
                }
            }
        }
        return false
    }
    
    class func surgicalHistoryCollectorHandler(taskResult: ORKTaskResult) -> ([[String: String]], Bool) {
        
        var shouldShowTaskAgain : Bool = false
        var surgeries = [[String:String]]()
        if let results = taskResult.results as? [ORKStepResult] {
            for stepResult: ORKStepResult in results {
                for result: ORKResult in stepResult.results! {
                    if let questionResult = result as? ORKChoiceQuestionResult where
                        questionResult.identifier == ActivitiesListRow.SurgicalHistoryIdentifier.Choice.rawValue {
                            surgeries = surgeryHistoryCollectorHandler(taskResult)
                    }
                    if let questionResult = result as? ORKBooleanQuestionResult {
                        if questionResult.identifier == "another_procedure_boolean" {
                            shouldShowTaskAgain = questionResult.booleanAnswer!.boolValue
                        }
                    }
                }
            }
        }

        print(surgeries)
        print(shouldShowTaskAgain)
        return (surgeries, shouldShowTaskAgain)
    }
    
    private class func surgeryHistoryCollectorHandler(taskResult: ORKTaskResult) -> [[String : String]] {
        
        /* create surgery, server:
        {
            "surgery_type":"Openvascular",,
            "surgery_location":"Left Tibials",
            "surgery_date":"1992-01-01T01:01:11.000Z",
        }
        */
        
        var surgeryDictionary = [String : String]() // arrray of surgerys dictionaries
        var surgeriesDictionary = [String : [String : String]]()
        
        if let results = taskResult.results as? [ORKStepResult] {
    
            for stepResult: ORKStepResult in results {
                
                for result: ORKResult in stepResult.results! {
                    
                    var key : String = ""
                    if let questionResult = result as? ORKTextQuestionResult { // Angiogram other type
                        
                        if questionResult.identifier ==  ActivitiesListRow.SurgicalHistoryIdentifier.Other.rawValue {
                            if let textAnswer = questionResult.textAnswer {
                                surgeryDictionary["surgery_type"] = String(textAnswer)
                                surgeriesDictionary[questionResult.identifier] = surgeryDictionary
                            }
                        }
                    }
                    
                    if let questionResult = result as? ORKDateQuestionResult {
                        if let answer = questionResult.dateAnswer {
                            key = ActivitiesListRow.SurgicalHistoryIdentifier.gerCorrespondingAngiogramKey(questionResult.identifier)
                            
                            surgeryDictionary["surgery_type"] = key
                            surgeryDictionary["surgery_date"] = answer.ISOStringFromDate()
                            surgeriesDictionary[key] = surgeryDictionary
                        }
                    }
                    
                    if let questionResult = result as? ORKChoiceQuestionResult,
                        let choiceAnswers = questionResult.choiceAnswers, let choice = choiceAnswers.first {
                        
                        if questionResult.identifier == ActivitiesListRow.SurgicalHistoryIdentifier.Location.rawValue {
                        
                            for key in surgeriesDictionary.keys {
                                if var surgery = surgeriesDictionary[key] {
                                    surgery["surgery_location"] = String(choice)
                                    surgeriesDictionary[key] = surgery
                                }
                            }
                            
                        } else {
                            
                            if ActivitiesListRow.SurgicalHistoryIdentifier.treatments.contains(questionResult.identifier) {
                                if surgeriesDictionary[questionResult.identifier] == nil {
                                    surgeryDictionary["surgery_type"] = questionResult.identifier
                                    surgeriesDictionary[questionResult.identifier] = surgeryDictionary
                                }
                            }
                            
                        }
                    }
                }
            }
        }
        
        return Array(surgeriesDictionary.values)
    }
    
    private class func surgicalHistoryOpenCollectorHandler(taskResult: ORKTaskResult) -> [String : [String : String]] {
        
        /* create surgery, server:
        {
        "surgery_type":"Openvascular",,
        "surgery_location":"Left Tibials",
        "surgery_date":"1992-01-01T01:01:11.000Z",
        }
        */
        
        var surgery = [String : String]() // arrray of surgerys dictionaries
        var surgeriesDictionary = [String : [String : String]]()
        
        if let results = taskResult.results as? [ORKStepResult] {

            for stepResult: ORKStepResult in results {
                for result: ORKResult in stepResult.results! {
                    if let questionResult = result as? ORKChoiceQuestionResult {
                        if questionResult.identifier != ActivitiesListRow.SurgicalHistoryIdentifier.Choice.rawValue {
                            if let choices = questionResult.choiceAnswers {
                                if let choice = choices.first {
                                    print(choice)
                                    surgery["surgery_type"] = String(choice)
                                    surgery["surgery_location"] = String(choice)
                                    surgeriesDictionary[questionResult.identifier] = surgery
                                }
                            }
                        }
                    }
                    
                    // Dates
                    if let questionResult = result as? ORKDateQuestionResult {
                        if let answer = questionResult.dateAnswer {
                            let key = ActivitiesListRow.SurgicalHistoryIdentifier.gerCorrespondingBypassKey(questionResult.identifier)
                            if surgeriesDictionary[key] != nil {
                                surgeriesDictionary[key]!["surgery_date"] = answer.ISOStringFromDate()
                            }
                        }
                    }
                }
            }
        }
        return surgeriesDictionary
    }
    

    class func physicalDataCollectorHandler(taskResult: ORKTaskResult) -> [String : AnyObject] {
        
        /* send to server:
         {
         "cramping_with_activity": false,
         "rest_improve_pain": false,
         "pain_with_exercise": false,
         "when_pain_occurs": null,
         "open_wounds": false,
         "walking_aids": [
         "Cane"
         ],
         "abi_right_leg":3.2,
         "abi_left_leg":1.5,
         "no_abi": false,
         }
         */
        
        var physicalDictionary = [String : AnyObject]()
        if let results = taskResult.results as? [ORKStepResult] {
            for stepResult: ORKStepResult in results {
                for result: ORKResult in stepResult.results! {
                    if let questionResult = result as? ORKQuestionResult {
                        if let answer = questionResult.answer {
                            if questionResult.identifier == "dont_know_abi" {
                                physicalDictionary[questionResult.identifier] = true
                            } else {
                                physicalDictionary[questionResult.identifier] = answer
                            }
                        }
                    }
                }
            }
        }
        
        print(physicalDictionary)
        return physicalDictionary
    }
    
    class func walkTestCollectorHandler(taskResult: ORKTaskResult) -> [String : AnyObject]? {
        
        /* server:
        {
        "date":"1990-01-02T01:01:11.000Z",
        "steps_day":400,
        "distance":200
        "stairs":15,
        "steps_without_stopping":20,
        }
        
        pedometer data:
        {
        distance = "35.13999999989755";
        endDate = "2016-03-25T14:23:21-0300";
        floorsAscended = 0;
        floorsDescended = 0;
        numberOfSteps = 28;
        startDate = "2016-03-25T14:33:27-0300";
        }
        */
        
        var walkDictionary = [String : AnyObject]()
        if let results = taskResult.results as? [ORKStepResult] {
            for stepResult: ORKStepResult in results {
                for result: ORKResult in stepResult.results! {
                    if let result = result as? ORKFileResult,
                        let fileUrl = result.fileURL,
                        let jsonData = NSData(contentsOfURL: fileUrl) {
                            do {
                                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary,
                                    let items = jsonResult["items"] as? NSArray,
                                    let pedometerData = items.lastObject as? NSDictionary { // the last item from the Pedometer mesurements
                                        if pedometerData["distance"] != nil {
                                            walkDictionary["distance"] = pedometerData["distance"] as! Double // NSNumber - meters
                                        }
                                        if pedometerData["floorsAscended"] != nil {
                                            walkDictionary["stairs"] = (pedometerData["floorsAscended"] as! Int) + (pedometerData["floorsDescended"] as! Int)
                                        }
                                        if pedometerData["startDate"] != nil {
                                            if let date = NSDate.dateFromString(pedometerData["startDate"] as! String) {
                                                walkDictionary["date"] = date.ISOStringFromDate()
                                            } else {
                                                walkDictionary["date"] = NSDate().ISOStringFromDate()
                                            }
                                        } else {
                                            walkDictionary["date"] = NSDate().ISOStringFromDate()
                                        }
                                        if pedometerData["numberOfSteps"] != nil {
                                            walkDictionary["steps_without_stopping"] = pedometerData["numberOfSteps"]
                                        }
                                }
                            } catch {
                                return nil
                            }
                    } else if let stopReason = result as? ORKChoiceQuestionResult {
                        if let choiceAnswers = stopReason.choiceAnswers as? [String] {
                            let boolDictionary = DataCollector.parseToBooleanDictionary(choiceAnswers, keys: ActivitiesListRow.WalkTestIdentifier.stoppingReasons)
                            
                            walkDictionary.append(boolDictionary)
                        }
                    }
                }
            }
        }
        
        return walkDictionary
    }
    
    
    // MARK : -Convenience
    class func parseToBooleanDictionary(dataSelected:[String], keys:[String]) -> [String: Bool] {
        var dictionary = [String: Bool]()
        
        for key in keys {
            if dataSelected.contains(key) {
                dictionary[key] = true
            } else {
                dictionary[key] = false
            }
        }
        return dictionary
    }

}
