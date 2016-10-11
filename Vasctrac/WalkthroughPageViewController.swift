//
//  WalkthroughPageViewController.swift
//  Vasctrac
//
//  Created by Kerolos Nakhla on 8/26/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class WalkthroughPageViewController: UIPageViewController, UIPageViewControllerDataSource {

    var pageImages = ["page_1", "page_2", "page_3", "page_4", "page_5", "page_6", "page_7"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Set the data source to self
        dataSource = self
        
        // Create the first walkthrough screen
        if let startingViewController = viewControllerAtIndex(0) {
            setViewControllers([startingViewController], direction: .Forward, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! LoginViewController).index
        index += 1
        
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! LoginViewController).index
        index -= 1
        
        return viewControllerAtIndex(index)
    }
    
    // MARK: - Helper method
    
    func viewControllerAtIndex(index: Int) -> LoginViewController? {
        if index == NSNotFound || index < 0 || index >= pageImages.count {
            return nil
        }
        
        // Create a new view controller and pass suitable data
        if let pageContentViewController = storyboard?.instantiateViewControllerWithIdentifier("LoginViewControllerTwo") as? LoginViewController {
            pageContentViewController.imageFile = pageImages[index]
            pageContentViewController.index = index
            
            return pageContentViewController
        }
        return nil
    }
    
//    func forward(index: Int) {
//        if let nextViewController = viewControllerAtIndex(index + 1) {
//            setViewControllers([nextViewController], direction: .Forward, animated: true, completion: nil)
//        }
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
