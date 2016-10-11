//
//  APIClient+Account.swift
//  Vasctrac
//
//  Created by Developer on 5/4/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import SwiftyJSON

extension APIClient {
    
    func login(withParameters parameters: [String: AnyObject], onCompletion:(([String : AnyObject]?, String?) -> Void)) {
        
        self.makeRequestWithErrorHandling(.POST, .Login, parameters: parameters) { response, error in
            guard error == nil else {
                onCompletion(nil, error)
                return
            }
            
            if let response = response {
                onCompletion(JSON(response).dictionaryObject, nil)
            }
        }
    }
    
    
    func register(parameters: [String: AnyObject], onCompletion:(([String : AnyObject]?, String?) -> Void)) {
        
        self.makeRequestWithErrorHandling(.POST, .Register, parameters: parameters) { response, error in
            guard error == nil else {
                onCompletion(nil, error)
                return
            }
            
            if let response = response {
                onCompletion(JSON(response).dictionaryObject, nil)
            }
        }
    }
    
    
    func currentUserData(onCompletion: (([String : AnyObject]?, String?) -> Void)) {
        
        self.makeRequestWithErrorHandling(.GET, .CurrentUser, parameters: nil) { response, error in
            if let response = response {
                onCompletion(JSON(response).dictionaryObject, nil)
            }
        }
    }
    
    
    func updateCurrentUser(data: [String: AnyObject], onCompletion:(([String : AnyObject]?, String?) -> Void)) {
        self.makeRequestWithErrorHandling(.PUT, .UpdateCurrentUser(userId), parameters: data) { response, error in
            guard error == nil else {
                onCompletion(nil, error)
                return
            }
            
            if let response = response {
                onCompletion(JSON(response).dictionaryObject, nil)
            }
        }
    }
    
    func verifyUserEmail(onCompletion:(([String : AnyObject]?, String?) -> Void)) {
        self.makeRequestWithErrorHandling(.POST, .VerifyEmail(userId)) { response, error in
            if let response = response {
                onCompletion(JSON(response).dictionaryObject, nil)
            }
        }
    }
    
    func isUserEmailVerified(onCompletion:(([String : AnyObject]?, String?) -> Void)) {
        self.makeRequestWithErrorHandling(.GET, .IsEmailVerified(userId)) { response, error in
            if let response = response {
                onCompletion(["verified" : response], nil)
            }
        }
    }
}
