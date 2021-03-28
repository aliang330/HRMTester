//
//  SelectedActivityController.swift
//  HRMTesterNew
//
//  Created by Allen Liang on 9/14/20.
//  Copyright © 2020 Allen Liang. All rights reserved.
//

import UIKit
import Charts

class SelectedActivityController: UIViewController {
    
    let activity: Activity
    
    var firstEntries = [ChartDataEntry]()
    var secondEntries = [ChartDataEntry]()
    
    var lineChart: LineChartView = {
        let chart = LineChartView()
        chart.rightAxis.enabled = false
        
        let yAxis = chart.leftAxis
        yAxis.setLabelCount(6, force: false)
        yAxis.labelPosition = .outsideChart
        
        chart.xAxis.labelPosition = .bottom
        
        return chart
    }()
    
    init(activity: Activity) {
        self.activity = activity
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChart()
    }
    
    func setupChart() {
        var time = 0
        for i in activity.hrDataFirstDevice {
            self.firstEntries.append(ChartDataEntry(x: Double(time), y: Double(i)))
            time += 1
        }
        
        time = 0
        
        for i in activity.hrDataSecondDevice {
            self.secondEntries.append(ChartDataEntry(x: Double(time), y: Double(i)))
            time += 1
        }
        
        //draw chart
        let set1 = LineChartDataSet(entries: firstEntries, label: activity.firstDeviceName)
        let set2 = LineChartDataSet(entries: secondEntries, label: activity.secondDeviceName)
        
        set1.lineWidth = 2
        set1.setColor(.red)
        set1.drawCirclesEnabled = false
        
        set2.lineWidth = 2
        set2.setColor(.cyan)
        set2.drawCirclesEnabled = false
        
        let data = LineChartData(dataSets: [set1, set2])
        
        data.setDrawValues(false)
        lineChart.data = data
        
    }
    
    func setupView() {
        
    }
}
