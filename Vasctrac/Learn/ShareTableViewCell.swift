//
//  ShareTableViewCell.swift
//  Vasctrac
//
//  Created by Developer on 3/10/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class ShareTableViewCell: UITableViewCell {

    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet weak var shareImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
