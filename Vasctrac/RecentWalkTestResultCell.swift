//
//  RecentWalkTestResultCell.swift
//  Vasctrac
//
//  Created by Developer on 5/19/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class RecentWalkTestResultCell: UITableViewCell {

    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var takenOnLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func distanceWalked(distance: String?) {
        if let distance = distance {
            self.distanceLabel.text = "\(distance) ft"
        }
    }

    func steps(steps: String?) {
        if let steps = steps {
            self.stepsLabel.text = steps
        }
    }
    
    func takenOn(dateString: String) {
        if let date = NSDate.dateFromISOString(dateString) {
            self.takenOnLabel.text = "Walk test taken on \(date.longFormattedString())"
        }
    }
}
