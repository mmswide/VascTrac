//
//  LoadingTableViewController.swift
//  Vasctrac
//
//  Created by Developer on 6/30/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class LoadingTableViewController: UITableViewController {
    
    private let loadingView = UIView()
    private let spinner = UIActivityIndicatorView()
    private let loadingLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLoadingScreen()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.startLoading()
    }
    
    func reloadData() {
        self.tableView.reloadData()
        self.stopLoading()
    }
    
    // Set the activity indicator into the main view
    private func setLoadingScreen() {
        
        // Sets the view which contains the loading text and the spinner
        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (self.tableView.frame.width / 2) - (width / 2)
        let y = (self.tableView.frame.height / 2) - (height / 2) - (self.navigationController?.navigationBar.frame.height)!
        loadingView.frame = CGRectMake(x, y, width, height)
        
        // Sets loading text
        self.loadingLabel.textColor = UIColor.grayColor()
        self.loadingLabel.textAlignment = NSTextAlignment.Center
        self.loadingLabel.text = "Loading..."
        self.loadingLabel.frame = CGRectMake(0, 0, 140, 30)
        
        // Sets spinner
        self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.spinner.frame = CGRectMake(0, 0, 30, 30)
        self.spinner.startAnimating()
        
        // Adds text and spinner to the view
        loadingView.addSubview(self.spinner)
        loadingView.addSubview(self.loadingLabel)
        
        self.tableView.addSubview(loadingView)
        
    }
    
    // Remove the activity indicator from the main view
    func stopLoading() {
        self.spinner.stopAnimating()
        self.loadingLabel.hidden = true
        
    }

    func startLoading() {
        self.spinner.startAnimating()
        self.loadingLabel.hidden = false
    }
    
}
