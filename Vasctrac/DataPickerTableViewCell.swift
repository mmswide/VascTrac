//
//  DataPickerTableViewCell.swift
//  Vasctrac
//
//  Created by Kerolos Nakhla on 9/6/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class DataPickerTableViewCell: UITableViewCell {

    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        datePicker.maximumDate = NSCalendar.currentCalendar().dateByAddingUnit(.Year, value: -18, toDate: NSDate(), options: [])
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
