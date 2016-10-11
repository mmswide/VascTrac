//
//  LineGraphChartTableViewCell.swift
//  Vasctrac
//
//  Created by Developer on 2/29/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import ResearchKit

class LineGraphChartTableViewCell: UITableViewCell {
    @IBOutlet weak var graphView: ORKGraphChartView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var todayValueLabel: UILabel!
    @IBOutlet weak var todayDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true
        self.layer.cornerRadius = 3.5
    }
}
