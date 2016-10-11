//
//  DailyHealthManager.swift
//  Vasctrac
//
//  Created by Developer on 3/29/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import HealthKit

class DailyHealthManager {

    // MARK: Singelton
    static let sharedManager = DailyHealthManager()
    
    var userAuthorizedHKOnDevice : Bool? {
        get {
            return NSUserDefaults.standardUserDefaults().valueForKey(Constants.UserDefaults.HKDataShare) as? Bool
        }
        set(newValue) {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: Constants.UserDefaults.HKDataShare)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    // MARK: Properties
    lazy var healthStore: HKHealthStore = HKHealthStore()
    
    // MARK: Healthkit read and write values
    let healthDataItemsToRead: Set<HKObjectType> = [
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed)!
    ]
    
    let healthDataItemsToWrite: Set<HKSampleType> = [
        HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!
    ]

    var alreadySentData : Bool = false
    
    // array of day data collector for each day
    var collectors = [DayDataCollector]()
    var countDaysToSend = 0
    var daysData = [[String:AnyObject]]()
    
    // full day of data is yesterday
    var fullDayOfData = NSDate()
    
    init() {
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(DailyHealthManager.sendDailyDataSinceLastDate),
                                                         name: UIApplicationDidBecomeActiveNotification,
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(DailyHealthManager.sendDailyDataSinceLastDate),
                                                         name: Constants.Notification.OnboardingCompleteNotification,
                                                         object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification,
                                                            object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.Notification.OnboardingCompleteNotification,
                                                            object: nil)
    }
    
    
    // MARK: Request Authorization
    
    func getHealthAuthorization(completion: (success: Bool, error: NSError?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            let error = NSError(domain: "com.stanford.vasctrac", code: 2, userInfo: [NSLocalizedDescriptionKey: "Health data is not available on this device."])
            
            completion(success: false, error:error)
            return
        }
        
        // Get authorization to access the actividata
        healthStore.requestAuthorizationToShareTypes(healthDataItemsToWrite, readTypes: healthDataItemsToRead) {
            [unowned self] success, error in
            
            self.userAuthorizedHKOnDevice = success
            
            if success {
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.sendDailyDataSinceLastDate()
                }
            }
            
            completion(success:success, error:error)
        }
    }
    
    @objc func sendDailyDataSinceLastDate() {
        
        guard HKHealthStore.isHealthDataAvailable() || TARGET_OS_SIMULATOR != 0 else {
            return
        }
        
        // check is there is a token, if not, then don't go forward
        guard SessionManager.sharedManager.accessToken != nil
            && SessionManager.sharedManager.currentUser != nil else {
            return
        }
        
        // steps data should be sent, since the last date of updation, till today
        let lastDateStepsDataSent = SessionManager.sharedManager.currentUser?.lastDateStepsDataSent
        
        if lastDateStepsDataSent == nil { // firt time sending data
            
            self.collectData(fullDayOfData) {
                self.sendDailyData(nil)
            }
            
        } else if lastDateStepsDataSent!.daysTo(fullDayOfData) == 0 { // update today data
            
            let idOfLastStepsDataSent = SessionManager.sharedManager.currentUser?.dailyDataLastSentId
            self.collectData(fullDayOfData) {
                self.sendDailyData(idOfLastStepsDataSent) // update sent data for this day
            }
    
        } else { // send data from previous days that was not sent
            
            countDaysToSend = lastDateStepsDataSent!.daysTo(fullDayOfData)
            
            for i in 0 ..< lastDateStepsDataSent!.daysTo(fullDayOfData) { // send data from the next day and on
                guard let day = lastDateStepsDataSent!.dayByAdding(i+1) else {
                    return
                }

                self.collectData(day) {
                    self.sendDailyData(nil)
                }
                
            }
        }
    }
    
    private func collectData(day: NSDate, onCompletion:(()->Void)) {
        
        // create new data collector for day
        let collector = DayDataCollector(withDay: day) { dayData, error in
            guard error == nil else {
                return
            }
            
            self.daysData.append(dayData!)
            NSOperationQueue.mainQueue().addOperationWithBlock {
                onCompletion()
            }
        }
        collectors.append(collector)
        
        // execture query for just added collector
        collectors.last!.queryHealthDataItems()
    }

    private func idDataOfDate(daysData: [AnyObject], date: NSDate) -> Int? {
        for dayData in daysData {
            if let dayData = dayData as? [String:AnyObject] {
                if dayData["date"] as! String == date.ISOStringFromDate() {
                    return dayData["id"] as? Int
                }
            }
        }
        return nil
    }
    
    private func sendDailyData(forId: String?) {
        
        let daysDataDict = ["daysData" : daysData]
        
        if let forId = forId { // is update
            if let dayData = daysData.first {
                APIClient.sharedClient.updateDailyData(forId, data: dayData, onCompletion: nil)
            }
        } else {
            APIClient.sharedClient.sendDailyData(daysDataDict) { daysDataArray, error in
                guard error == nil else {
                    return
                }
                
                // save today data id
                if let daysDataArray = daysDataArray {
                    if let todayId = self.idDataOfDate(daysDataArray, date: self.fullDayOfData) {
                
                        SessionManager.sharedManager.currentUser?.dailyDataSent(withDate: self.fullDayOfData,
                                                                                andDataId: String(todayId))
                    }
                }
            }
        }
    }
}
