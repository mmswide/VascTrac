//
//  RegisterViewController.swift
//  Vasctrac
//
//  Created by Developer on 5/20/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import TextFieldEffects
import ResearchKit

class RegisterViewController: UserViewController {
   
    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextBarButton: UIBarButtonItem!
    
    let toEmailVerificationSegueId = "toEmailVerification"
    var userFirstName : String? { return SessionManager.sharedManager.userSignatureFirstName }
    var userLastName : String? { return SessionManager.sharedManager.userSignatureLastName }
    
    enum RegistrationCellType : Int {
        case Password = 0
        case Birthday
        case DatePicker
        case Gender
        
        var identifier : String {
            switch self {
            case .Password:
                return "passwordTextFieldCell"
            case .Birthday:
                return "birthdayTextFieldCell"
            case .Gender:
                return "genderTableViewCell"
            case .DatePicker:
                return "datePickerCell"
            }
        }
        
        static let all = [Password, Birthday, Gender]
        static let allWithPicker = [Password, Birthday, DatePicker, Gender]
    }
    
    enum FieldType : Int {
        case Name = 0
        case Email
        case Password
    }

    var rowCount = RegistrationCellType.all.count
    var pickerDisplayed = false
    var pickerIndexPath : NSIndexPath? = nil
    var pickedBday : String? = nil
    var userInfo = [String:AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // do not show empty cells
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        nextBarButton.enabled = false
        
        // set user full name collected at consent
        if let userLastName = userLastName, let userFirstName = userFirstName {
            userInfo["last_name"] = userLastName
            userInfo["first_name"] = userFirstName
            fullName?.text = "\(userFirstName) \(userLastName)"
        }
    }
    
    @IBAction func next(sender: UIBarButtonItem) {
        self.view.endEditing(true)
        
        if verifyAll(withEmptiness: true) {
            SessionManager.sharedManager.register(userInfo) { [unowned self] success in
                guard success else {
                    return
                }
                
                // save image to user if any
                if let profileImage = self.profileImage {
                    SessionManager.sharedManager.currentUser?.profilePicture(UIImagePNGRepresentation(profileImage))
                }
                
                self.toPasscode()
            }
        }
    }
    
    func verifyAll(withEmptiness emptyness: Bool) -> Bool {
    
        var valid = false
        
        // verify text fields
        for textField in view.subviewsOfType(HoshiTextField.self) {
            if textField.text!.isEmpty {
                if emptyness {
                    textField.changePlaceholderText("This can’t be empty", withError: true)
                }
                valid = false
            } else {
                switch FieldType(rawValue: textField.tag)! {
                case .Email:
                    valid = textField.isValidEmail(withDefaultPlaceholderText: "Email")
                case .Password:
                    valid = textField.isValidPassword(withDefaultPlaceholderText: "Add Password")
                default : break
                }
            }
        }
        
        valid = userInfo["gender"] != nil
        valid = pickedBday != nil
        
        if valid {
            self.nextBarButton.enabled = true
        }
        
        return valid
    }

    // MARK: - Navigation
    
    func toPasscode() {
        let passcodeStep = ORKPasscodeStep(identifier: "passcode_step")
        let passcodeTask = ORKOrderedTask(identifier: "passcode_task", steps: [passcodeStep])
        let taskViewController = ORKTaskViewController(task: passcodeTask, taskRunUUID: nil)
        taskViewController.delegate = self
        self.presentViewController(taskViewController, animated: true, completion: nil)
    }
    
    func toEmailVerification() {
        self.performSegueWithIdentifier(toEmailVerificationSegueId, sender: nil)
    }
}

extension RegisterViewController  : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var dequeueFrom = pickerDisplayed ? RegistrationCellType.allWithPicker : RegistrationCellType.all
        let cell = tableView.dequeueReusableCellWithIdentifier(dequeueFrom[indexPath.row].identifier, forIndexPath: indexPath)
        
        switch dequeueFrom[indexPath.row] {
        case .Birthday:
            if let pickedBday = pickedBday,
            let bday = NSDate.dateFromISOString(pickedBday) {
                (cell as! RegisterTextFieldCell).content(bday.longFormattedString())
            }
        case .Gender:
            (cell as! SegmentedCell).delegate = self
        default:
            break
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var dequeueFrom = pickerDisplayed ? RegistrationCellType.allWithPicker : RegistrationCellType.all
        
        if pickerDisplayed {
            switch dequeueFrom[indexPath.row] {
            case .DatePicker: // display picker cell
                return 164
            case .Gender:
                return 76
            default:
                return 60
            }
        }
        
        switch dequeueFrom[indexPath.row] {
        case .Gender:
            return 76
        default:
            return 60
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch RegistrationCellType(rawValue: indexPath.row)! {
        case .Birthday: // display picker cell
            !pickerDisplayed ? showPicker(indexPath) : hidePicker()
        default :
            if pickerDisplayed {
                hidePicker()
            }
        }
    }
}

extension RegisterViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        let hoshiTextField = textField as! HoshiTextField
        switch FieldType(rawValue: textField.tag)! {
        case .Name:
            if hoshiTextField.text!.isNotEmpty {
                SessionManager.sharedManager.currentUser?.fullName(hoshiTextField.text!)
            } else {
                hoshiTextField.changePlaceholderText("Name", withError: false)
            }
        case .Email:
            if hoshiTextField.isValidEmail(withDefaultPlaceholderText: "Email") {
                userInfo["email"] = hoshiTextField.text!
            }
        case .Password:
            if hoshiTextField.isValidPassword(withDefaultPlaceholderText: "Add Password") {
                userInfo["password"] = hoshiTextField.text!
            }
        }
    
        self.verifyAll(withEmptiness: false)
    }
    
}

extension RegisterViewController : UIPickerViewDelegate {
    
    @IBAction func datePickerValueChanged(sender: UIDatePicker) {
        self.pickedBday = sender.date.ISOStringFromDate()
        userInfo["date_of_birth"] = self.pickedBday
        self.verifyAll(withEmptiness: false)
        self.tableView.reloadData()

    }
    
    func showPicker(indexPath: NSIndexPath) {
        self.view.endEditing(true)
        
        rowCount = RegistrationCellType.allWithPicker.count
        pickerDisplayed = true
        
        pickerIndexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)
        
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths([pickerIndexPath!], withRowAnimation: .Fade)
        self.tableView.endUpdates()
        
        self.tableView.scrollToRowAtIndexPath(pickerIndexPath!, atScrollPosition: .Bottom, animated: true)
    }
    
    func hidePicker() {
        rowCount = RegistrationCellType.all.count
        pickerDisplayed = false
        
        self.tableView.beginUpdates()
        self.tableView.deleteRowsAtIndexPaths([pickerIndexPath!], withRowAnimation: .Fade)
        self.tableView.endUpdates()
    }
    
}

extension RegisterViewController : SegmentedDelegate {
    
    func didSelectSegment(selectedSegmentIndex : Int) {
        userInfo["gender"] = selectedSegmentIndex
    
    }
}

extension RegisterViewController : ORKTaskViewControllerDelegate {
    
    func taskViewController(taskViewController: ORKTaskViewController, didFinishWithReason reason: ORKTaskViewControllerFinishReason, error: NSError?) {
        if reason == .Completed {
            dismissViewControllerAnimated(true) { [unowned self] in
                self.toEmailVerification()
            }
        }
    }
}
