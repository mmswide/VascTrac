//
//  WalkTestResult.swift
//  Vasctrac
//
//  Created by Developer on 6/13/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import RealmSwift

class WalkTestResult: Object {
    
    /*
     date = "0001-01-01T00:00:01.000Z";
     distance = 6;
     id = 45;
     stairs = 0;
     "steps_without_stopping" = 8;
     "stopping_reason_interrupted" = 0; // stopping reason isn't needed
     "stopping_reason_leg_hurt" = 0;
     "stopping_reason_tired" = 0;
     */
    
    dynamic var date : String = ""
    dynamic var distance : Double = 0
    dynamic var id : String = ""
    dynamic var stairs : Int = 0
    dynamic var steps_without_stopping : Int = 0
    
}
