//
//  UserDetailsViewController.swift
//  Vasctrac
//
//  Created by Developer on 5/24/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import TextFieldEffects

class UserDetailsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var headerLineHeight: NSLayoutConstraint!
    
    enum DetailCellType : Int {
        case Height = 0
        case HeightPicker
        case Weight
        
        var identifier : String {
            switch self {
            case .Height:
                return "heightCell"
            case .HeightPicker:
                return "heightPickerCell"
            case .Weight:
                return "weightCell"
            }
        }
        
        static let all = [Height, Weight]
        static let allWithPicker = [Height, HeightPicker, Weight]
    }
    
    private var pickerIndexPath : NSIndexPath? = nil
    private var dequeueFrom : [DetailCellType] = DetailCellType.all
    private var pickerDisplayed = false
    private var pickedHeight : String? = nil
    private var userInfo = [String:AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // do not show empty cells
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        //Looks for single or multiple taps.
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        self.headerLineHeight.constant = 0.5
    }
    
    func dismissKeyboard() {
        if pickerDisplayed {
            hidePicker()
        }
        self.tableView.endEditing(true)
    }
    
    // MARK: - Navigation
    
    @IBAction func next(sender: UIButton) {
         self.view.endEditing(true)
        
        if pickerDisplayed {
            hidePicker()
        }
        
        ActivitySpinner.spinner.show()
        SessionManager.sharedManager.updateUser(userInfo) { error in
            ActivitySpinner.spinner.hide()
            guard error == nil else {
                return
            }
            self.toUserMainContact()
        }
    }
    
    @IBAction func skip(sender: UIButton) {
        if pickerDisplayed {
            hidePicker()
        }
        
        toUserMainContact()
    }
    
    func toUserMainContact() {
        performSegueWithIdentifier("toMainContact", sender: nil)
    }
    
}

extension UserDetailsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dequeueFrom.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(dequeueFrom[indexPath.row].identifier, forIndexPath: indexPath)
        
        switch dequeueFrom[indexPath.row] {
        case .Height:
            if let pickedHeight = pickedHeight {
                (cell as! RegisterTextFieldCell).content(pickedHeight)
            }
        case .HeightPicker:
            let pickerCell = (cell as! PickerTableViewCell)
            pickerCell.type = .Custom
            pickerCell.delegate = self
        default:
            break
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
        if pickerDisplayed {
            switch dequeueFrom[indexPath.row] {
            case .HeightPicker : // display picker cell
                return 164
            default:
                return 60
            }
        }
        
        return 60
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch DetailCellType(rawValue: indexPath.row)! {
        case .Height: // display picker cell
            !pickerDisplayed ? showPicker(indexPath) : hidePicker()
        default :
            if pickerDisplayed {
                hidePicker()
            }
        }
    }
}

extension UserDetailsViewController : PickerViewDelegate {
    
    func pickerViewDidSelectIndices(cell: PickerTableViewCell, heightStringValue: String, heightInInches: Double) {
        self.pickedHeight = heightStringValue
//        TODO: once height type in server is changed, send height
        userInfo["height"] = Int(heightInInches)
        self.tableView.reloadData()
    }
    
    func showPicker(indexPath: NSIndexPath) {
        self.view.endEditing(true)
        
        dequeueFrom = DetailCellType.allWithPicker
        pickerDisplayed = true
        
        pickerIndexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)
        
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths([pickerIndexPath!], withRowAnimation: .Fade)
        self.tableView.endUpdates()
        
        self.tableView.scrollToRowAtIndexPath(pickerIndexPath!, atScrollPosition: .Bottom, animated: true)
    }
    
    func hidePicker() {
        dequeueFrom = DetailCellType.all
        pickerDisplayed = false
        
        self.tableView.beginUpdates()
        self.tableView.deleteRowsAtIndexPaths([pickerIndexPath!], withRowAnimation: .Fade)
        self.tableView.endUpdates()
    }
}

extension UserDetailsViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        if textField.text!.isNotEmpty {
            userInfo["weight"] = Double(textField.text!)
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if pickerDisplayed {
            hidePicker()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
