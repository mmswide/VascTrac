//
//  DayDataCollector.swift
//  Vasctrac
//
//  Created by Developer on 5/6/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import HealthKit

class DayDataCollector {

    lazy var healthStore: HKHealthStore = HKHealthStore()
    
    private let maxNonStopSteps = "max_non_stop_steps"
    private let totalDistance = "distance_walked"
    private let totalSteps = "total_steps"
    private let totalFlights = "flights_climbed"
    
    var dayData = [String: AnyObject]()
    var day : NSDate
    
    var completionHandler : (([String: AnyObject]?, String?) -> Void)? = nil
    
    init(withDay day: NSDate, andCompletionHandler completionHandler:(([String: AnyObject]?, String?) -> Void)) {
        self.day = day
        self.dayData["date"] = self.day.ISOStringFromDate()
        self.completionHandler = completionHandler
    }
    
    func queryHealthDataItems() {
        
        // predicate
        let predicate = HKQuery.predicateForSamplesWithStartDate(day.startOfDay(), endDate: day.endOfDay(), options: .None)
        
        // the sort descriptor to return the samples in ascending order
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: true)
        
        self.querySteps(predicate, sortDescriptor)
        self.queryDistance(predicate, sortDescriptor)
        self.queryFlights(predicate, sortDescriptor)
        
    }
    
    private func querySteps(predicate: NSPredicate?, _ sortDescriptor: NSSortDescriptor) {
        let steps = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!
        
        let query =
            HKSampleQuery(sampleType: steps,
                predicate: predicate,
                limit: Int(HKObjectQueryNoLimit),
            sortDescriptors: [sortDescriptor]) { [unowned self] query, results, error in
                guard error == nil else { // there was an error reading from healthKit
                    self.completionHandler?(nil, error?.description)
                    return
                }
                
                var maxSteps = 0
                var totalSteps = 0
                if let results = results as? [HKQuantitySample] {
                    
                    let stepsData = self.stepsData(results)
                    
                    if let max = stepsData.0 {
                        maxSteps = max
                    }
                    
                    if let total = stepsData.1 {
                        totalSteps = total
                    }
                    
                }
                self.dayData[self.totalSteps] = totalSteps
                self.dayData[self.maxNonStopSteps] = maxSteps
                self.checkCompletion()
            }
        self.healthStore.executeQuery(query)
    }
    
    private func queryDistance(predicate: NSPredicate?, _ sortDescriptor: NSSortDescriptor) {
        let distance = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!
        
        let sumOption = HKStatisticsOptions.CumulativeSum
        healthStore.executeQuery(
            HKStatisticsQuery(quantityType: distance,
                quantitySamplePredicate: predicate,
            options: sumOption) { [unowned self] query, result, error in
                guard error == nil else { // there was an error reading from healthKit
                    self.completionHandler?(nil, error?.description)
                    return
                }
                
                var value = 0
                if let sumQuantity = result?.sumQuantity() {
                    value = Int(sumQuantity.doubleValueForUnit(HKUnit.meterUnit()))
                }
                self.dayData[self.totalDistance] = value
                self.checkCompletion()
            }
        )
    }
    
    private func queryFlights(predicate: NSPredicate?, _ sortDescriptor: NSSortDescriptor) {
        let flights = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed)!
        
        let sumOption = HKStatisticsOptions.CumulativeSum
        healthStore.executeQuery(
            HKStatisticsQuery(quantityType: flights,
                quantitySamplePredicate: predicate,
            options: sumOption) { [unowned self] query, result, error in
                guard error == nil else { // there was an error reading from healthKit
                    self.completionHandler?(nil, error?.description)
                    return
                }
                
                var value = 0
                if let sumQuantity = result?.sumQuantity() {
                     value = Int(sumQuantity.doubleValueForUnit(HKUnit.countUnit()))
                }
                self.dayData[self.totalFlights] = value
                self.checkCompletion()
            }
        )
    }
    
    private func checkCompletion() {
        
        guard dayData[maxNonStopSteps] != nil else {
            return
        }
        
        guard dayData[totalSteps] != nil else {
            return
        }
        
        guard dayData[totalDistance] != nil else {
            return
        }
        
        guard dayData[totalFlights] != nil else {
            return
        }
        
        self.completionHandler?(dayData, nil)
    }

    
    // MARK: - Convenience
    
    // The greatest number of steps walked withouth stopping     
    // Stopping: when the user stops walking for more than one minute
    private func stepsData(daySample: [HKQuantitySample]) -> (max: Int?, total: Int?) {
        
        var countSamples = [Int]()
        var samplesSum = 0
        var i = 0
        var startIndex = 0
        while i < daySample.count {
            
            startIndex = i
            samplesSum = Int(daySample[startIndex].quantity.doubleValueForUnit(HKUnit.countUnit()))
            
            // check if next sample start date is less than one minute than the currentEnd date
            while i + 1 < daySample.count && (daySample[i].endDate).isLessThanOneMinute(daySample[i + 1].startDate) {
                i += 1
                samplesSum += Int(daySample[i].quantity.doubleValueForUnit(HKUnit.countUnit()))
            }
            
            countSamples.append(samplesSum)
            i += 1
        }
        
        let max = countSamples.maxElement()
        let total = countSamples.reduce(0) {$0 + $1}
        
        return (max, total)
    }

}
