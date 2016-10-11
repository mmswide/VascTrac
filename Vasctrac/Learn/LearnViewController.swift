//
//  LearnViewController.swift
//  Vasctrac
//
//  Created by Developer on 3/10/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class LearnViewController: UITableViewController {
    
    let sectionsContent = [
        [
            "type": "share",
            "title": "Spread the Word",
            "image": "spread_icon"
        ],
        
        [
            "type": "about",
            "title": "About this Study",
            "html": "About",
            "image": "about_icon"
        ],
        
        [
            "type": "how",
            "title": "How this Study Works",
            "html": "HowWorks",
            "image": "how_icon"
        ],
        
        [
            "type": "eligibility",
            "title": "Who Can Participate",
            "html": "Participate",
            "image": "who_icon"
        ],
        
        [
            "type": "what",
            "title": "What is Peripheral Artery Disease (PAD)?",
            "html": "PAD",
            "image": "pad_icon"
        ],
        
        [
            "type": "symptoms",
            "title": "Symptoms",
            "html": "Symptoms",
            "image": "symptoms_icon"
        ],
        
        [
            "type": "treatment",
            "title": "Treatment",
            "html": "Treatment",
            "image": "treatment_icon"
        ],
        
        [
            "type":"online",
            "title": "Online Resources",
            "html": "Online",
            "image": "online_icon"
        ]
    ]
    
    enum learnSectionType {
        case About
        case Symptoms
        case Eligibility
        case Share
        case Treatment
        case Online
    }
    
    let kLearnCellIdentifier = "LearnCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // do not show empty cells
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sectionsContent.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: LearnTableViewCell = tableView.dequeueReusableCellWithIdentifier(kLearnCellIdentifier) as! LearnTableViewCell
        let rowContent = sectionsContent[indexPath.row]
        cell.titleLabel.text = rowContent["title"]
        cell.imageIcon?.image = UIImage.init(imageLiteral: rowContent["image"]!)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let rowContent = sectionsContent[indexPath.row]
        let sectionType = toSectionType(rowContent["type"])
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        switch sectionType {
        case .Share:
            performSegueWithIdentifier("toShare", sender: nil)
        default:
            performSegueWithIdentifier("toWebView", sender: cell)
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 25
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toWebView" {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)!
            let webViewController = segue.destinationViewController as! DetailWebViewController
            let content = self.sectionsContent[indexPath.row]
            webViewController.content = content["html"]
            webViewController.contentTitle = content["title"]
        }
    }
    
    
    func toSectionType(sectionTypeName: String?) -> learnSectionType {
        var sectionType: learnSectionType = .About
        
        if (sectionTypeName == String(learnSectionType.About).lowercaseString) {
            sectionType = .About
        }
        else if (sectionTypeName == "symptoms") {
            sectionType = .Symptoms
        }
        else if (sectionTypeName == "eligibility") {
            sectionType = .Eligibility
        }
        else if (sectionTypeName == "share") {
            sectionType = .Share
        }
        else if (sectionTypeName == "treatment") {
            sectionType = .Treatment
        }
        else if (sectionTypeName == "Online") {
            sectionType = .Online
        }
        return sectionType
    }
    
}
