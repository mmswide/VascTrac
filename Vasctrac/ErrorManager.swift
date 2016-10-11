//
//  ErrorManager.swift
//  Vasctrac
//
//  Created by Developer on 4/25/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import Foundation

class ErrorManager {
    
    static let sharedManager = ErrorManager()
    static var fatalErrorList = [String]() // any of this errors will exit the app
    
    let errorKey = "user_error"
    
    init() {
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(ErrorManager.showAPIUserError),
                                                         name:Constants.Notification.APIUserErrorNotification,
                                                         object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: Constants.Notification.APIUserErrorNotification,
                                                            object: nil)
    }
    
    @objc func showAPIUserError(notification: NSNotification) {
        if let error = notification.userInfo {
            let errorText = error[errorKey] as! String
            let alert = UIAlertController.errorAlert(errorText)
            if let topViewController = UIApplication.topViewController() {
                topViewController.presentViewController(alert, animated: true, completion: nil)
            }
        }
        return
    }
    
    func showErrorOnTop(error: String) {
        let alert = UIAlertController.errorAlert(error)
        if let topViewController = UIApplication.topViewController() {
            topViewController.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func addFatalError(error: String) {
        ErrorManager.fatalErrorList.append(error)
    }
    
    func showFatalError(inViewController viewController: UIViewController) {
        for error in ErrorManager.fatalErrorList {
            let alert = UIAlertController(title:  "Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { alert in
                exit(0)
            }))
            viewController.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func isUserTokenExpiration(error: String) -> Bool {
        return error.containsString("token is expired")
    }
}
