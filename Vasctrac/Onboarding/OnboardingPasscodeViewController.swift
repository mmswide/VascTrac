//
//  OnboardingPasscodeViewController.swift
//  Vasctrac
//
//  Created by Developer on 3/7/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import ResearchKit
import HealthKit

class OnboardingPasscodeViewController: UIViewController {

    var passcodeAsked : Bool = false

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        guard ErrorManager.fatalErrorList.count == 0 else {
            ErrorManager.sharedManager.showFatalError(inViewController: self)
            return
        }
        
        // if passcode already asked "passcodeAsked",
        // the user already entered the passcode and there is a token in the keychain
        // so if "passcodeAsked" go to research
        guard !passcodeAsked else {
            
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notification.OnboardingCompleteNotification,
                                                                      object: nil)
            
            toResearch()
            
            return
        }
        
        guard SessionManager.sharedManager.currentUser != nil else {
            toOnboarding()
            return
        }
        
        // if there is a token in the keychain
        guard SessionManager.sharedManager.accessToken != nil else {
            toOnboarding()
            return
        }
        
        // if there is a passcode
        guard ORKPasscodeViewController.isPasscodeStoredInKeychain() else {
            toOnboarding()
            return
        }
        
        toPasscode()
    }
    
    func toResearch() {
        self.performSegueWithIdentifier("toResearch", sender: self)
    }

    func toOnboarding() {
       performSegueWithIdentifier("toOnboarding", sender: nil)
    }
    
    func toPasscode() {
        let passcodeViewController = ORKPasscodeViewController.passcodeAuthenticationViewControllerWithText("", delegate: self) as! ORKPasscodeViewController
        self.presentViewController(passcodeViewController, animated: false, completion: nil)
    }
    
}

extension OnboardingPasscodeViewController: ORKPasscodeDelegate {
    func passcodeViewControllerDidFinishWithSuccess(viewController: UIViewController) {
        passcodeAsked = true
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func passcodeViewControllerDidFailAuthentication(viewController: UIViewController) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
        
        let alert = UIAlertController(title: "Wrong Passcode Entered", message:"", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Okay",
            style: UIAlertActionStyle.Default,
            handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
