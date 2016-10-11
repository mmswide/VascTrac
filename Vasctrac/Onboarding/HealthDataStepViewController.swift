//
//  HealthDataStepViewController.swift
//  Vasctrac
//
//  Created by Developer on 3/2/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import ResearchKit

class HealthDataStepViewController: ORKInstructionStepViewController {
    
    override func goForward() {
        DailyHealthManager.sharedManager.getHealthAuthorization() { succeeded, error in
            // The second part of the guard condition allows the app to proceed on the Simulator (where health data is not available)
            guard succeeded || (TARGET_OS_SIMULATOR != 0) else {
                if let error = error {
                    print(error)
                }
                return
            }
            
            NSOperationQueue.mainQueue().addOperationWithBlock {
                super.goForward()
            }
        }
    }
}
