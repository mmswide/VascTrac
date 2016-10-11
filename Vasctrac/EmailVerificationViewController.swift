//
//  EmailVerificationViewController.swift
//  Vasctrac
//
//  Created by Developer on 5/24/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class EmailVerificationViewController: UIViewController {

    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set current user email
        emailLabel.text = SessionManager.sharedManager.currentUser?.email
        
        self.navigationItem.setHidesBackButton(true, animated:true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.sendVerificationEmail()
    }
    
    private func sendVerificationEmail() {
        SessionManager.sharedManager.verifyUserEmail { success in
            guard success else {
                ErrorManager.sharedManager.showErrorOnTop("There was an error sending your email, please try resending")
                return
            }

        }
    }
    
    @IBAction func continueNotVerified(sender: UIButton) {
        self.performSegueWithIdentifier("toUserDetails", sender: nil)
    }

    @IBAction func continueIfVerified(sender: UIButton) {
        
        ActivitySpinner.spinner.show()
        SessionManager.sharedManager.isUserEmailVerified { isVerified in
            ActivitySpinner.spinner.hide()
            guard isVerified else {
                let title = NSLocalizedString("Your email has not yet been verified", comment: "")
                let message = NSLocalizedString("Please check your inbox to verify your email for VascTrac", comment: "")
                let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                alertController.view.tintColor = UIColor.vasctracTintColor()
                
                return
            }
            
            self.performSegueWithIdentifier("toUserDetails", sender: nil)
        }
    }
    
    @IBAction func wrongEmailTapped(sender: AnyObject) {
        let alertController = UIAlertController(title: "Change your Email", message: "",
                                                preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addTextFieldWithConfigurationHandler { textField in
            textField.keyboardType = .EmailAddress
            textField.placeholder = "Enter Email"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default) { alert in
            let emailTextField = alertController.textFields![0] as UITextField
            if let email = emailTextField.text {
                SessionManager.sharedManager.currentUser?.changeEmail(email)
                self.emailLabel.text = email
                // TODO : Change this once server allows changing user email
                SessionManager.sharedManager.updateUser(["email" : email]) { sucess in
                    self.emailLabel.text = email
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler:nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func resendVerificationEmail(sender: UIButton) {
        self.sendVerificationEmail()
        
        let alertController = UIAlertController(title: "", message: "A new verification email was sent to \(SessionManager.sharedManager.currentUser?.email)", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
