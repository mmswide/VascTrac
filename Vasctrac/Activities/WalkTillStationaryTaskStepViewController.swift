//
//  WalkTillStationaryTaskStepViewController.swift
//  Vasctrac
//
//  Created by Developer on 3/23/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import ResearchKit
import CoreMotion

class WalkTillStationaryTaskStepViewController: ORKActiveStepViewController {
    
    let MAX_ELAPSED_TIME = 15*60 // 15 minutes
    let MIN_STEPS_PER_MINUTE = 10 // minimun count of steps in a minute to consider the user has stopped
    
    var isAlreadyTiming: Bool = false
    var numberOfSteps: Int = 0
    
    var countdownStationaryTimer : NSTimer!
    var timerCountdown : Double = 0
    var elapsedTimer : NSTimer!
    var elapsedTime : Int = 0

    let pedometer: CMPedometer! = CMPedometer()
    
    var previousTotalStepsTaken : Int = 0
    var totalStepsTaken : Int = 0
    var stepsSinceLastMinute : Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customView = WalkTillStationaryContentView()
        
        let customView = self.customView as! WalkTillStationaryContentView
        customView.stopButton.addTarget(self, action: #selector(WalkTillStationaryTaskStepViewController.stopTapped), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.customView?.translatesAutoresizingMaskIntoConstraints = false
        
        self.suspendIfInactive = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.start()
    }
    
    override func start() {
        super.start()
        
        // Start Timers
        self.startElapsedTimer()
        
        // start pedometer
        self.startPedometer()
    }
    
    func startElapsedTimer() {
        self.elapsedTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(WalkTillStationaryTaskStepViewController.updateElapsedTime), userInfo: nil, repeats: true)
    }
    
    private func finishStep() {
        self.elapsedTimer.invalidate()
        
        // user has been stationary for more than one minute
        self.suspend()
        self.finish()
    }
    
    func stopTapped() { // explicitly stopped activity
        self.finishStep()
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func updateElapsedTime() {
        elapsedTime += 1
        let customView = self.customView as! WalkTillStationaryContentView
        let secondsToHMS = secondsToHoursMinutesSeconds(elapsedTime)
        let text = secondsToHMS.0 != 0 ? "\(secondsToHMS.0):\(String(format: "%02d", secondsToHMS.1)):\(String(format: "%02d", secondsToHMS.2))" : "\(String(format: "%02d", secondsToHMS.1)):\(String(format: "%02d", secondsToHMS.2))"
        customView.timeLabel?.text = text
        
        if elapsedTime % 60 == 0 {
            if elapsedTime == 60 { // first minute
                self.stepsSinceLastMinute = self.totalStepsTaken
                self.previousTotalStepsTaken = self.totalStepsTaken
            } else {
                self.stepsSinceLastMinute = self.totalStepsTaken - self.previousTotalStepsTaken
                self.previousTotalStepsTaken = self.totalStepsTaken
            }
            
            if self.stepsSinceLastMinute < MIN_STEPS_PER_MINUTE {
                self.finishStep()
            }
        }
        
        if elapsedTime == MAX_ELAPSED_TIME {
            self.finishStep()
        }
    }
    
    
    func stationaryInterval() -> Double { // now is one minute
        let step = self.step as! WalkTillStationaryTaskStep
        return step.maxStationaryDuration
    }
    
    
    // MARK: - Recorders
    
    func pedometerRecorderDidUpdate(pedometer: CMPedometer) {
        print(pedometer)
    }
    
    override func recorder(recorder: ORKRecorder, didCompleteWithResult result: ORKResult?) {
        super.recorder(recorder, didCompleteWithResult: result)
        
        if recorder.identifier == "pedometer" {
            print(recorder)
        }
    }
    
    
    // MARK: - Pedometer
    
    func updateDistance(distance: Double) {
        let customView = self.customView as! WalkTillStationaryContentView
        customView.distanceLabel?.text = distance.metersToFeetString() + "ft"
    }
    
    func startPedometer() {
        if CMPedometer.isStepCountingAvailable() {
            self.pedometer.startPedometerUpdatesFromDate(NSDate()) { [unowned self] pedometerData, error in
                
                if let pedometerData = pedometerData {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        
                        self.totalStepsTaken = Int(pedometerData.numberOfSteps)
                        (self.customView as? WalkTillStationaryContentView)?.output?.text = String(self.totalStepsTaken)
                        
                        if let distance = pedometerData.distance {
                            // average step length is approximated automatically by multiplying body height by 0.413
                            self.updateDistance(distance.doubleValue)
                        }
                    }
                }
                
            }
        }
    }
    
}