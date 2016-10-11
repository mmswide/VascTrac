//
//  APIClient+Messages.swift
//  Vasctrac
//
//  Created by Developer on 6/14/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import SwiftyJSON
import ObjectMapper

extension APIClient {
    
    func userMessages(onCompletion: (([Message]?, String?) -> Void)) {
        self.makeRequestWithErrorHandling(.GET, .Messages(userId)) { response, error in
            guard error == nil else {
                onCompletion(nil,error)
                return
            }
            
            if let response = response {
                let json = JSON(response)
                if let objectData = json.arrayObject {
                    if let result = Mapper<Message>().mapArray(objectData) {
                        onCompletion(result, nil)
                    } else {
                        onCompletion(nil, error)
                    }
                }
            }
        }
    }
    
    func didReadMessage(withId id: String, onCompletion: Bool -> Void) {
        self.makeRequestWithErrorHandling(.POST, .MessageRead(userId,id)) { response, error in
            guard error == nil else {
                onCompletion(false)
                return
            }
            
            if let _ = response {
                onCompletion(true)
            }
        }
    }
}
