//
//  WalkTillStationaryTaskStep.swift
//  Vasctrac
//
//  Created by Developer on 3/23/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import ResearchKit

class WalkTillStationaryTaskStep: ORKActiveStep {
    
    var maxStationaryDuration : NSTimeInterval!
    
    static func stepViewControllerClass() -> AnyObject {
        return WalkTillStationaryTaskStepViewController.self
    }
    
    override init(identifier: String) {
        super.init(identifier: identifier)
        self.commonInit()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func commonInit() {
        self.shouldShowDefaultTimer = false
        self.shouldVibrateOnStart = true
        self.shouldVibrateOnFinish = true
    }
    
    func startsFinished() -> Bool {
        return false
    }

}
