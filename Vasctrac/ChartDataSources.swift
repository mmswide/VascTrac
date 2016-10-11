/*
Copyright (c) 2015, James Cox. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1.  Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2.  Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3.  Neither the name of the copyright holder(s) nor the names of any contributors
may be used to endorse or promote products derived from this software without
specific prior written permission. No license is granted to the trademarks of
the copyright holders even if such marks are included in this software.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import ResearchKit

class PeriodicLineGraphDataSource: NSObject, ORKGraphChartViewDataSource {
    
    var plotPoints = [CGFloat]()
    var type : Period = .Week // what kinf od period is, Week by default
    
    func numberOfPlotsInGraphChartView(graphChartView: ORKGraphChartView) -> Int {
        return 1
    }
    
    func graphChartView(graphChartView: ORKGraphChartView, pointForPointIndex pointIndex: Int, plotIndex: Int) -> ORKRangedPoint {
        return ORKRangedPoint(value: plotPoints[pointIndex])
    }
    
    func graphChartView(graphChartView: ORKGraphChartView, numberOfPointsForPlotIndex plotIndex: Int) -> Int {
        
        graphChartView.noDataText = plotPoints.count == 0 ? "No Data" : ""
        
        return plotPoints.count
    }
    
    func maximumValueForGraphChartView(graphChartView: ORKGraphChartView) -> CGFloat {
        
        return plotPoints.maxElement() ?? 0
    }
    
    func minimumValueForGraphChartView(graphChartView: ORKGraphChartView) -> CGFloat {
        return 0
    }
    
    func graphChartView(graphChartView: ORKGraphChartView, titleForXAxisAtPointIndex pointIndex: Int) -> String? {
        
        let now = NSDate()
        let timeAgo = self.plotPoints.count - pointIndex
        
        switch type {
        case .Year:
            if let day = now.monthByAdding(-timeAgo) {
                return day.getMonth()
            }
        default:
            if let day = now.dayByAdding(-timeAgo) {
                let step = type == .Month ? 5 : 1
                
                if pointIndex % step != 0 {
                    return nil
                }
                
                let prevDay = day.dayByAdding(-step)
                
                let addMonth = pointIndex == 0 || (prevDay?.getMonth() != day.getMonth())
                
                if addMonth {
                    return "\(day.getDay()) \(day.getMonth())"
                } else {
                    return  "\(day.getDay())"
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Convenience
    
    func pointsAvg() -> CGFloat {
        if plotPoints.count > 0 {
            return plotPoints.reduce(0) {$0 + $1} / CGFloat(plotPoints.count)
        }
        return 0
    }
    
}
