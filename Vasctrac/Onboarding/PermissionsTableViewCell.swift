//
//  PermissionsTableViewCell.swift
//  Vasctrac
//
//  Created by Developer on 3/11/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class PermissionsTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var allowButton: BorderButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func disableAllowButton() {
        self.allowButton.enabled = false
        self.allowButton.setTitle("Granted", forState: .Disabled)
        self.allowButton.disable()
    }

}
