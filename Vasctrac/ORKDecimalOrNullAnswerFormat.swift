//
//  ORKDecimalOrNullAnswerFormat.swift
//  Vasctrac
//
//  Created by Developer on 7/24/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import ResearchKit

class ORKDecimalOrNullAnswerFormat: ORKNumericAnswerFormat {
    
    func isAnswerValidWithString(string: NSString?) -> Bool {
        
        if let string = string {
            if string.length == 0 {
                return true
            }
            
            let numberFormatter = NSNumberFormatter()
            numberFormatter.locale = NSLocale.currentLocale()
            let number = numberFormatter.numberFromString(string as String)
            
            return number != nil
            
        } else {
            return true
        }
    }
    
}
