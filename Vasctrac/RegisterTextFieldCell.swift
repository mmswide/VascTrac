//
//  RegisterTextFieldCell.swift
//  Vasctrac
//
//  Created by Developer Labs on 5/23/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class RegisterTextFieldCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func content(content : String) {
        contentLabel.text = content
        contentLabel.textColor = UIColor.greyishColor()
    }
}
