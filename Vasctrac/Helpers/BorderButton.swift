//
//  BorderButton.swift
//  Vasctrac
//
//  Created by Developer on 3/4/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class BorderButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    func setUp() {
        self.layer.cornerRadius = 5.0
        self.layer.borderColor = UIColor.vasctracTintColor().CGColor
        self.layer.borderWidth = 1.0
        self.layer.masksToBounds = true
        self.contentHorizontalAlignment = .Center
        self.contentEdgeInsets = UIEdgeInsetsMake(13,25,13,25)
        self.setTitleColor(UIColor.vasctracTintColor(), forState: .Normal)
    }
    
    func disable() {
        self.layer.borderColor = UIColor.grayColor().CGColor
        self.setTitleColor(UIColor.grayColor(), forState: .Disabled)
    }
}
