//
//  ActivitiesTableViewCell.swift
//  Vasctrac
//
//  Created by Developer on 2/29/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class ActivitiesTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var completionImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func complete() {
        self.completionImageView.image = UIImage.init(imageLiteral:"check")
    }
}
