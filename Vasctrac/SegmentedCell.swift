//
//  SegmentedCell.swift
//  Vasctrac
//
//  Created by Developer on 5/23/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

protocol SegmentedDelegate {
    func didSelectSegment(selectedSegmentIndex : Int)
}

class SegmentedCell: UITableViewCell {

    enum GenderTag : Int {
        case Male = 0
        case Female
    }
    
    var delegate : SegmentedDelegate? = nil
    
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    
    @IBAction func segmentTapped(sender: UIButton) {
        sender.setTitleColor(UIColor.greyishColor(), forState: .Normal)
        
        self.delegate?.didSelectSegment(sender.tag)
        
        switch GenderTag(rawValue:sender.tag)! {
        case .Male:
            femaleButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        case .Female:
            maleButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        }
  
    }
    
    
    
}
