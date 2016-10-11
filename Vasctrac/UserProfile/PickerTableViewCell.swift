//
//  PickerTableViewCell.swift
//  Vasctrac
//
//  Created by Developer on 4/12/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

enum PickerType {
    case Custom
    case Date
}

@objc protocol PickerViewDelegate {
    optional func datePickerValueChanged(cell: PickerTableViewCell,  date: NSDate)
    optional func pickerViewDidSelectIndices(cell: PickerTableViewCell, heightStringValue: String, heightInInches: Double)
}

class PickerTableViewCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var delegate : PickerViewDelegate?
    
    var pickerData = [
        ["0'", "1'", "2'", "3'", "4'", "5'", "6'", "7'", "8'"],
        ["0''", "1''", "2''", "3''", "4''", "5''", "6''", "7''", "8''", "9''", "10''", "11''"]
    ]

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var type : PickerType = .Date {
        didSet {
            switch (type) {
            case .Custom:
                self.datePicker.hidden = true
                self.pickerView.hidden = false
            case .Date:
                self.datePicker.hidden = false
                self.pickerView.hidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        
        self.datePicker.datePickerMode = .Time
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    // MARK: - UIPickerViewDataSource methods - Height
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[component][row]
    }
    
    // MARK: - UIPickerViewDelegate methods - Height
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var selectedRowIndices = [String]()
        
        for i in 0..<pickerData.count {
            selectedRowIndices.append(pickerData[i][pickerView.selectedRowInComponent(i)])
        }
        
        let selectedStringValue = selectedRowIndices.joinWithSeparator(" ")
        let heightInInches = heightInInchesForSelectedIndices(selectedRowIndices)
        self.delegate?.pickerViewDidSelectIndices!(self, heightStringValue: selectedStringValue, heightInInches: heightInInches)
    }
    
    // MARK: - DatePickerValueChanged
    
    @IBAction func datePickerValueChanged(sender: UIDatePicker) {
        if self.delegate != nil {
            self.delegate!.datePickerValueChanged!(self, date: sender.date)
        }
    }
    
    
    // MARK: - Convenience
    
    func heightInInchesForSelectedIndices(selectedIndices: [AnyObject]) -> Double {
        let feet = (selectedIndices[0]).doubleValue
        let inches = (selectedIndices[1]).doubleValue
        let totalInches: Double = (12 * feet) + inches
        return totalInches
    }
    
}
