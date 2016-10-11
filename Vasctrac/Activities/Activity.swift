//
//  Activity.swift
//  Vasctrac
//
//  Created by Developer on 3/9/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import ResearchKit

class Activity {
    
    var description: String = ""
    var task : ORKTask? = nil
    var complete : Bool = false
    
    init(task: ORKTask?) {
        self.task = task
    }
}
