//
//  HealthDataStep.swift
//  Vasctrac
//
//  Created by Developer on 3/2/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import ResearchKit
import HealthKit

class HealthDataStep: ORKInstructionStep {
    
    static func stepViewControllerClass() -> AnyObject {
        return HealthDataStepViewController.self
    }
    
    // MARK: Initialization
    
    override init(identifier: String) {
        super.init(identifier: identifier)
        
        title = NSLocalizedString("Sensor and Health Data", comment: "")
        text = NSLocalizedString("In the next screen, you will be prompted to grant VascTrac access to read and write some your activity data. Please turn All Categories On to enroll in the study.", comment: "")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}