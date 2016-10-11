//
//  ActivitySpinner.swift
//  Vasctrac
//
//  Created by Developer on 5/3/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class ActivitySpinner {

    // shared instance
    static let spinner = ActivitySpinner()
    
    private var overlayView = UIView()
    private var activityIndicator = UIActivityIndicatorView()
    
    // shows an activity indicator on top of the topViewController
    func show() {
        if let topViewController = UIApplication.topViewController() {
            
            topViewController.view.endEditing(true) // force to resign all first responders
            
            overlayView.frame = CGRectMake(0, 0, 80, 80)
            overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            overlayView.center = topViewController.view.center
            overlayView.clipsToBounds = true
            overlayView.layer.cornerRadius = 10
            
            activityIndicator = UIActivityIndicatorView(frame:  CGRectMake(0, 0, 40, 40))
            activityIndicator.activityIndicatorViewStyle = .WhiteLarge
            activityIndicator.center = CGPointMake(overlayView.bounds.width / 2, overlayView.bounds.height / 2)
            
            overlayView.addSubview(activityIndicator)
            
            topViewController.view.addSubview(overlayView)
            activityIndicator.startAnimating()
        }
    }
    
    func hide() {
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
    }
    
}
