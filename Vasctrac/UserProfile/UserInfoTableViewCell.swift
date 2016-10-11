//
//  UserInfoTableViewCell.swift
//  Vasctrac
//
//  Created by Developer on 3/13/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class UserNameTextField: UITextField {}

class UserInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var detailTextField: UITextField! {
        didSet {
            detailTextField.enabled = false
            detailTextField.userInteractionEnabled = false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setEnableEditing() {
        detailTextField.enabled = true
        detailTextField.userInteractionEnabled = true
        detailTextField.becomeFirstResponder()
    }
}
