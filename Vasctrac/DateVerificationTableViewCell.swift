//
//  DateVerificationTableViewCell.swift
//  Vasctrac
//
//  Created by Kerolos Nakhla on 9/6/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class DateVerificationTableViewCell: UITableViewCell {

    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // TODO: uncomment line below to restrict picker for only picking 18 years and older dates
        // datePicker.maximumDate = NSCalendar.currentCalendar().dateByAddingUnit(.Year, value: -18, toDate: NSDate(), options: [])

        
        
//        let cal = NSCalendar.currentCalendar()
//        datePicker.datePickerMode = .Date
//        datePicker.maximumDate = cal.startOfDayForDate(cal.dateByAddingUnit(.Year, value: -18, toDate: NSDate(), options: [])!)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
