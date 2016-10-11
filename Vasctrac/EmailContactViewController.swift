//
//  EmailContactViewController.swift
//  Vasctrac
//
//  Created by Developer on 5/25/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class EmailContactViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var headerLineHeight: NSLayoutConstraint!
    
    private var userInfo = [String:AnyObject]()

    let toSurveysSegueId = "toSurveys"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // do not show empty cells
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        //Looks for single or multiple taps.
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        self.headerLineHeight.constant = 0.5
    }
    
    func dismissKeyboard() {
        self.tableView.endEditing(true)
    }
    
    @IBAction func next(sender: UIButton) {
        
        if userInfo["doctor_or_family_email"] != nil {
            ActivitySpinner.spinner.show()
            SessionManager.sharedManager.updateUser(userInfo) { error in
                ActivitySpinner.spinner.hide()
                guard error == nil else {
                    let alert = UIAlertController(title: "Error", message: error,
                                                  preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    return
                }
                self.toSurveys()
            }
        } else {
            toSurveys()
        }
    }
    
    @IBAction func skip(sender: UIButton) {
        toSurveys()
    }
    
    func toSurveys() {
        performSegueWithIdentifier(toSurveysSegueId, sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == toSurveysSegueId {
            if let surveysVC = segue.destinationViewController as? SurveysViewController {
                surveysVC.surveysType = .Onboarding
                surveysVC.onCompletion = { _ in
                    let researchVC = UIStoryboard(name: "Main",
                        bundle: nil).instantiateViewControllerWithIdentifier("researchTabBarController")
                    self.navigationController?.presentViewController(researchVC, animated: true, completion: nil)
                }
            }
        }
    }
    
}

extension EmailContactViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("emailCell", forIndexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension EmailContactViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        if isValidEmail(textField.text!) {
            userInfo["doctor_or_family_email"] = textField.text!
        } else {
            let alert = UIAlertController(title: "Email not valid", message: "Please enter a valid email",
                                                    preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func isValidEmail(text:String) -> Bool {
        
        let emailValidationRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        if text.isNotEmpty {
            if !NSPredicate(format: "SELF MATCHES %@", emailValidationRegex).evaluateWithObject(text) {
                return false
            }
        }
        return true
    }
}
