//
//  EligibilityCriteriaViewController.swift
//  Vasctrac
//
//  Created by Developer on 3/4/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class EligibilityCriteriaViewController: UITableViewController {
    
    var selectedQuestions = [Bool](count:3, repeatedValue: false)
    @IBOutlet var answers: [ExclusiveButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.tintColor = UIColor.vasctracTintColor()
    }
    
    
    @IBAction func didSelectAnswer(sender: ExclusiveButton) {
        let questionIndex = sender.questionIndex
        let answerIndex = sender.answerIndex
        
        self.selectedQuestions[questionIndex] = !Bool(answerIndex)
        
        let complementIndex = answerIndex == 0 ? questionIndex*2+1 : questionIndex*2
        let complementAnswer = answers[complementIndex]
        
        complementAnswer.setTitleColor(UIColor.greyishColor(), forState: .Normal)
        sender.setTitleColor(UIColor.vasctracTintColor(), forState: .Normal)
        sender.layoutIfNeeded()
        complementAnswer.layoutIfNeeded()
    }

    func isElegible() -> Bool {
        var elegible = false
        if self.selectedQuestions[0] &&
           self.selectedQuestions[1] &&
           self.selectedQuestions[2] {
            elegible = true
        }
        return elegible
    }
    
    
    // MARK: - Navigation

    @IBAction func nextTapped(sender: UIBarButtonItem) {
        performSegueWithIdentifier("toJoinViewController", sender: nil)
    }
    
    @IBAction func backTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toJoinViewController" {
            let resultVC = segue.destinationViewController as! JoinViewController
            resultVC.elegible = isElegible()
        }
    }
    

}
