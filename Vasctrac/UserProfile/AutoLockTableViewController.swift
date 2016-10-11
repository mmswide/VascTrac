//
//  AutoLockTableViewController.swift
//  Vasctrac
//
//  Created by Developer on 3/14/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class AutoLockTableViewController: UITableViewController {

    let lockTimes = [
        "5", "10", "15", "30", "45"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "timeCell")
        cell.textLabel?.text = lockTimes[indexPath.row] + " minutes"
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if let cell = cell {
            cell.accessoryType = .Checkmark
        }
    }
}
