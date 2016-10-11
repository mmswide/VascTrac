//
//  APIClient+Dashboard.swift
//  Vasctrac
//
//  Created by Developer on 5/4/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import SwiftyJSON

extension APIClient {
    
    func dashboardTrends(forPeriod period: Period, onCompletion: (([String : AnyObject]?, String?) -> Void)) {
        
        let parameters = [
            "period" : period.rawValue
        ]
        
        self.makeRequestWithErrorHandling(.GET, .DashboardTrends(userId), parameters: parameters,
                                          encoding: .URLEncodedInURL) { response, error in
            /*
             {
              "daysData": 
                [
                {
                  "Type": "day",
                  "Date": "2016-05-08T00:00:00-04:00",
                  "MaxNonStopSteps": 181,
                  "TotalSteps": 0,
                  "DistanceWalked": 0,
                  "FlightsClimbed": 0
                },
                {
                  "Type": "day",
                  "Date": "2016-05-09T00:00:00-04:00",
                  "MaxNonStopSteps": 0,
                  "TotalSteps": 0,
                  "DistanceWalked": 0,
                  "FlightsClimbed": 0
                }
                ]
             }
             */
            if let response = response {
                onCompletion(JSON(response).dictionaryObject, nil)
            }
        }
    }

}
