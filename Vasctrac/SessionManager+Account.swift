//
//  SessionManager+Account.swift
//  Vasctrac
//
//  Created by Developer on 5/4/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import SwiftyJSON

extension SessionManager {
    
    func login(email: String, password: String, onCompletion:(Bool -> Void)) {
        
        let parameters = [
            "email" : email,
            "password" : password,
//            "apn" : SessionManager.sharedManager.deviceToken!
            "apn" : "12345678979435497"
        ]
        
        ActivitySpinner.spinner.show()
        APIClient.sharedClient.login(withParameters: parameters) { response, error in
            ActivitySpinner.spinner.hide()
            
            guard error == nil else {
                ErrorManager.sharedManager.showErrorOnTop(error!)
                return
            }
            
            self.handleTokenResponse(response, error) { success in
                onCompletion(success)
            }
        }
    }
    
    func register(data: [String: AnyObject], onCompletion:(Bool -> Void)) {
        var parameters = data
        parameters["apn"] = SessionManager.sharedManager.deviceToken ?? ""

        ActivitySpinner.spinner.show()
        APIClient.sharedClient.register(parameters) { [unowned self] response, error in
            ActivitySpinner.spinner.hide()
            
            guard error == nil else {
                ErrorManager.sharedManager.showErrorOnTop(error!)
                return
            }
            
            self.handleTokenResponse(response, error) { success in
                onCompletion(success)
            }
        }
    }
    
    func verifyUserEmail(onCompletion:(Bool -> Void)) {
        
        APIClient.sharedClient.verifyUserEmail { response, error in
            guard error == nil else {
                onCompletion(false)
                return
            }
            
            onCompletion(true)
        }
    }
    
    func isUserEmailVerified(onCompletion:(Bool -> Void)) {
        
        APIClient.sharedClient.isUserEmailVerified { response, error in
            guard error == nil else {
                onCompletion(false)
                return
            }
            
            if response!["verified"] as! NSNumber == 1
            {
                onCompletion(true)
            }else{
                onCompletion(false)

            }
        }
    }
    
    // MARK: - User Access
    
    private func handleTokenResponse(response: [String : AnyObject]?, _ error: String?,
                                     onCompletion: (Bool -> Void)) {
        
        guard error == nil else {
            onCompletion(false)
            return
        }
        
        if let response = response {
            let jsonResponse = JSON(response)
            let token = jsonResponse["response"]["user"]["authorization_token"].stringValue
            
            SessionManager.sharedManager.accessToken = token

            APIClient.sharedClient.currentUserData { [unowned self] userData, error in
                guard error == nil else {
                    onCompletion(false)
                    return
                }
    
                guard let user = self.mapUser(userData!) else {
                    onCompletion(false)
                    return
                }
    
                // save as currentUser
                self.currentUser = user
                
                onCompletion(true)
            }
        }
    }
}
