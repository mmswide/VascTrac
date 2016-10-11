//
//  SessionManager.swift
//  Vasctrac
//
//  Created by Developer on 5/3/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import RealmSwift
import ResearchKit
import SSKeychain
import SwiftyJSON

class SessionManager {

    static let sharedManager = SessionManager()
    
    // Get the default Realm
    let realm = try! Realm()
    
    // MARK: - Name the user introduces in consent signing
    var userSignatureFirstName : String? = nil
    var userSignatureLastName : String? = nil

    // MARK: - User
    private lazy var _currentUser : User? = {
        return self.realm.objects(User).first
    }()
    var currentUser : User? {
        get {
            return _currentUser
        }
        set(newValue) {
            let tmpUser = realm.objectForPrimaryKey(User.self, key: (newValue?.userId)!)
            if newValue != nil && tmpUser != nil{ // delete user
                try! realm.write {

                    if let user = _currentUser {
                        realm.delete(user)
                    }
                }
            } else {
                try! realm.write {
                    realm.add(newValue!)
                }
            }
            _currentUser = newValue
        }
    }
    
    
    // MARK : - Token
    private lazy var _accessToken : String? = {
        return SSKeychain.passwordForService(Constants.Keychain.AppIdentifier,
                                             account: Constants.Keychain.TokenIdentifier)
    }()
    var accessToken : String? {
        get {
            return _accessToken
        }
        set(newValue) {
            _accessToken = newValue
            if newValue == nil { // delete user token
                SSKeychain.deletePasswordForService(Constants.Keychain.AppIdentifier,
                                                    account: Constants.Keychain.TokenIdentifier)
            } else {
                SSKeychain.setPassword(newValue, forService: Constants.Keychain.AppIdentifier,
                                       account: Constants.Keychain.TokenIdentifier)
            }
        }
    }
    
    // MARK: -Remote notifications token
    private lazy var _deviceToken : String? = {
        return NSUserDefaults.standardUserDefaults().valueForKey(Constants.UserDefaults.DeviceToken) as? String
    }()
    var deviceToken : String? {
        get {
            return _deviceToken
        }
        set(newValue) {
            _deviceToken = newValue
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: Constants.UserDefaults.DeviceToken)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    // MARK: - Initialization
    
    init() {
        // Observers
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(sessionExpired),
                                                         name: Constants.Notification.SessionExpired,
                                                         object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.Notification.SessionExpired, object: nil)
    }
    
    func updateUser(data: [String: AnyObject], onCompletion:(String? -> Void)?) {
        guard currentUser != nil else {
            onCompletion?(nil)
            return
        }
        
        APIClient.sharedClient.updateCurrentUser(data) { updatedUserData, error in
            guard error == nil else {
                onCompletion?(error)
                return
            }
            
            if let user = self.mapUser(updatedUserData!) {
                try! self.realm.write {
                    self.realm.add(user, update: true)
                }
                onCompletion?(nil)
            } else {
                onCompletion?("There was an issue saving this data")
            }
        }
    }
    
    func removeUser() {
        // delete user
        currentUser = nil
        
        // remove token from keychain
        accessToken = nil
        
        // remove passcode
        if ORKPasscodeViewController.isPasscodeStoredInKeychain() {
            ORKPasscodeViewController.removePasscodeFromKeychain()
        }
    }
    
    
    @objc func sessionExpired() {
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController")
        
        if let topViewController = UIApplication.topViewController() {
            topViewController.presentViewController(loginVC, animated: true, completion: {
                self.removeUser()
            })
        }
    }
    
    // MARK: - Convenience
    func mapUser(data: [String: AnyObject]) -> User? {
        
        let json = JSON(data)
        
        guard json["first_name"] != nil else {
            return nil
        }
        guard json["last_name"] != nil else {
            return nil
        }
        guard json["email"] != nil else {
            return nil
        }
        guard json["ID"] != nil else {
            return nil
        }
        
        var userDict = json.dictionaryObject!
        userDict["userId"] = json["ID"].numberValue.stringValue
        
        return User(value: userDict)
    }
    

    // MARK: - User Defaults
    
    func checkFirstRun() {
        if self.getFirstRun() == nil { // app never run before
            self.removeUser()
            self.setFirstRun()
        }
    }
    
    private func setFirstRun() {
        NSUserDefaults.standardUserDefaults().setObject(true, forKey: Constants.UserDefaults.FirstRun)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    private func getFirstRun() -> Bool? {
        return NSUserDefaults.standardUserDefaults().valueForKey(Constants.UserDefaults.FirstRun) as? Bool
    }
    
}
