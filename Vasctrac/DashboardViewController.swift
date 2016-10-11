//
//  DashboardViewController.swift
//  Vasctrac
//
//  Created by Developer on 3/25/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import ResearchKit

protocol AnimatableChart {
    func animateWithDuration(animationDuration: NSTimeInterval)
}
extension ORKPieChartView : AnimatableChart {}
extension ORKLineGraphChartView : AnimatableChart {}


enum TrendType : Int {
    case MaxSteps = 0
    case TotalSteps
    case DistanceWalked
    case FlightsClimbed
    
    static let allValues = [MaxSteps, TotalSteps, DistanceWalked, FlightsClimbed]
}

enum Period : String {
    case Day = "day"
    case Week = "week"
    case Month = "month"
    case Year = "year"
}


class DashboardViewController: UIViewController {
    
    var maxStepsDataSource = PeriodicLineGraphDataSource()
    var totalStepsDataSource = PeriodicLineGraphDataSource()
    var distanceWalkedDataSource = PeriodicLineGraphDataSource()
    var flightsClimbedDataSource = PeriodicLineGraphDataSource()
    
    lazy var periodicDataSources : [PeriodicLineGraphDataSource] = {
        var periodicDataSources = [PeriodicLineGraphDataSource]()
        periodicDataSources.append(self.maxStepsDataSource)
        periodicDataSources.append(self.totalStepsDataSource)
        periodicDataSources.append(self.distanceWalkedDataSource)
        periodicDataSources.append(self.flightsClimbedDataSource)
        return periodicDataSources
    }()
    
    var currentPeriod : Period = .Week // default is week
    
    lazy var lineChartTitles = [
        NSLocalizedString("Max Steps Without Stopping", comment: ""),
        NSLocalizedString("Total Steps", comment: ""),
        NSLocalizedString("Distance Walked", comment: ""),
        NSLocalizedString("Flights Climbed", comment: "")
    ]
    
    lazy var lineChartCellColorBackground = [
        UIColor.init(netHex: 0xFFE3E8, alpha: 0.67),
        UIColor.init(netHex: 0xEEFDFF),
        UIColor.init(netHex: 0xF0F0FF),
        UIColor.init(netHex: 0xE0FFF1)
    ]
    
    lazy var lineChartLineColor = [
        UIColor.init(netHex: 0xFF6F8B),
        UIColor.init(netHex: 0x4CB8F5),
        UIColor.init(netHex: 0x957AED),
        UIColor.init(netHex: 0x4ED89E)
    ]
    
    var animatableCharts = [UIView]()
    
    let lineGraphChartIdentifier = "LineGraphChartCell"
    
    var events = [AnyObject]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        UITableViewHeaderFooterView.appearance().tintColor = UIColor.whiteColor()
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hideBottomHairline()
        
        self.reloadDashboardData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.showBottomHairline()
    }
    
    private func reloadDashboardData() {
        
        // Request server for data sources data
        ActivitySpinner.spinner.show()
        APIClient.sharedClient.dashboardTrends(forPeriod: self.currentPeriod) { dashboardData, error in
            ActivitySpinner.spinner.hide()
            guard error == nil else {
                print("error on getting dashboard data")
                return
            }
            
            if dashboardData != nil,
                let daysDataDicts = dashboardData!["daysData"] as? [[String: AnyObject]] {
                
                for dataSource in self.periodicDataSources {
                
                    // stablish the type
                    dataSource.type = self.currentPeriod
                
                    // clean previous loaded data
                    dataSource.plotPoints.removeAll()
                }
                
                for dayData in daysDataDicts {
                    self.maxStepsDataSource.plotPoints.append(dayData["MaxNonStopSteps"] as! CGFloat)
                    self.totalStepsDataSource.plotPoints.append(dayData["TotalSteps"] as! CGFloat)
                    self.distanceWalkedDataSource.plotPoints.append(dayData["DistanceWalked"] as! CGFloat)
                    self.flightsClimbedDataSource.plotPoints.append(dayData["FlightsClimbed"] as! CGFloat)
                }
                
                
            }
            
            self.tableView.reloadData()
        }
    }
    
    @IBAction func periodChanged(sender: UISegmentedControl) {
        
        self.currentPeriod = Period(rawValue: sender.titleForSegmentAtIndex(sender.selectedSegmentIndex)!.lowercaseString)!
        self.reloadDashboardData()
    }
    
    // MARK: Convenience
    
    func animatableChartInCell(cell: UITableViewCell) -> AnimatableChart? {
        for chart in animatableCharts {
            guard let animatableChart = chart as? AnimatableChart where chart.isDescendantOfView(cell) else { continue }
            return animatableChart
        }
        return nil
    }
    
    func averagePrefix() -> String {
        
        var averagePrefix = ""
        
        switch self.currentPeriod {
        case .Day:
            averagePrefix += "Daily"
        case .Week:
            averagePrefix += "Weekly"
        case .Month:
            averagePrefix += "Monthly"
        case .Year:
            averagePrefix += "Annual"
        }
        
        averagePrefix += " average"
        
        return averagePrefix
    }
}

extension DashboardViewController : UITableViewDataSource, UITableViewDelegate {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return TrendType.allValues.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 3 { //last section
            return 15
        }
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 250
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let index = indexPath.section
        
        let lineCell = self.tableView.dequeueReusableCellWithIdentifier(self.lineGraphChartIdentifier) as! LineGraphChartTableViewCell
        lineCell.backgroundColor = self.lineChartCellColorBackground[index]
        
        let lineChartView = lineCell.graphView as! ORKLineGraphChartView
        self.animatableCharts.append(lineChartView)
        
        lineCell.titleLabel?.text = self.lineChartTitles[index]
        lineChartView.tintColor = self.lineChartLineColor[index] // line color
        lineChartView.showsHorizontalReferenceLines = true
        lineChartView.showsVerticalReferenceLines = true
        
        var trendPoints : [CGFloat]? = nil
        switch TrendType(rawValue: indexPath.section)! {
        case .MaxSteps:
            lineChartView.dataSource = self.maxStepsDataSource
            trendPoints = self.maxStepsDataSource.plotPoints
            
            let avg = self.maxStepsDataSource.pointsAvg()
            lineCell.subtitleLabel?.text =  averagePrefix() + ": \(Int(avg)) steps"
            
        case .TotalSteps:
            lineChartView.dataSource = self.totalStepsDataSource
            trendPoints = self.totalStepsDataSource.plotPoints
            
            let avg = self.totalStepsDataSource.pointsAvg()
            lineCell.subtitleLabel?.text = averagePrefix() + ": \(Int(avg)) steps"
            
        case .DistanceWalked:
            lineChartView.dataSource = self.distanceWalkedDataSource
            trendPoints = self.distanceWalkedDataSource.plotPoints
            
            let avg = self.distanceWalkedDataSource.pointsAvg()
            lineCell.subtitleLabel?.text = averagePrefix() + ": " + Double(avg).metersToFeetString() + " ft"
            
        case .FlightsClimbed:
            lineChartView.dataSource = self.flightsClimbedDataSource
            trendPoints = self.flightsClimbedDataSource.plotPoints
            
            let avg = self.flightsClimbedDataSource.pointsAvg()
            lineCell.subtitleLabel?.text = averagePrefix() + ": \(Int(avg)) flights"
        }

        if let trendPoints = trendPoints where trendPoints.count > 0 {
            
            
            lineCell.todayDateLabel?.text = NSDate().timeToString()
            lineCell.todayValueLabel?.text = Int(trendPoints.last!) == 0 ? "No value" : String(Int(trendPoints.last!)) // last value corresponds to today
        }
        
        return lineCell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // Animate charts as they're scrolled into view.
        if let animatableChart = animatableChartInCell(cell) {
            animatableChart.animateWithDuration(0.5)
        }
    }
}
