//
//  AllSetContentViewController.swift
//  Vasctrac
//
//  Created by Developer on 3/7/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class AllSetContentViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.estimatedRowHeight = 108.0;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        
        self.navigationController?.navigationBarHidden = true
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
}
