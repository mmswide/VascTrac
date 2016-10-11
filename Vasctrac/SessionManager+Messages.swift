//
//  SessionManager+Messages.swift
//  Vasctrac
//
//  Created by Developer on 6/29/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

extension SessionManager {

    @objc func userMessages(onCompletion: (([Message]?, String?) -> Void)) {
        
        if accessToken != nil {
            APIClient.sharedClient.userMessages { messages, error in
                guard error == nil else {
                    onCompletion(nil,error)
                    return
                }
                
                if let messages = messages {
                    onCompletion(messages,nil)
                }
            }
        }
    }
    
    func didReadMessage(withId id: String, onCompletion: Bool -> Void) {
        APIClient.sharedClient.didReadMessage(withId: id) { success in
            onCompletion(success)
        }
    }
    
}
