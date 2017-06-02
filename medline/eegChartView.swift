//
//  AccelChartView.swift
//  medline
//
//  Created by Bailey Blankenship on 5/25/17.
//  Copyright © 2017 Bailey Blankenship. All rights reserved.
//

import Foundation
import Charts

class EegChartView : MedlineLineChartView {
    public var holding : Bool = false
    
    var eegEntries : [ChartDataEntry] = []
    
    var eegDataSet : LineChartDataSet!
    
    var chartData : ChartData!
    var chartDataSets : [LineChartDataSet]!
    
    let chartColors : [UIColor] = [.accent]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initChart()
    }
    
    func initChart(){
        eegDataSet = LineChartDataSet(values: eegEntries, label: "EEG")
        
        chartDataSets = [eegDataSet]
        
        for (index, dataSet) in chartDataSets.enumerated() {
            dataSet.drawCirclesEnabled = false
            dataSet.cubicIntensity = 1.0
            dataSet.drawValuesEnabled = false
            dataSet.lineWidth = 2
            dataSet.setColor(chartColors[index])
        }
        
        chartData = LineChartData(dataSets: chartDataSets)
        data = chartData
    }
    
    func addToGraph(packet: Data, date: Date, range: Int?){
        let timestamp = date.timeIntervalSince1970
        
        let eeg = (Int(packet[0]) << 16) + (Int(packet[1]) << 8) + (Int(packet[2]))
        
        let eegEntry = ChartDataEntry(x: timestamp, y: Double(eeg))
        
        if let range = range {
            if (lineData?.dataSets[0].entryCount)! > range {
                let first = lineData?.dataSets[0].entryForIndex(0)
                
                xAxis.axisMinimum = (first?.x)!
                
                _ = lineData?.dataSets[0].removeFirst()
            }
        }
        
        data?.addEntry(eegEntry, dataSetIndex: 0)
        
        if !holding {
            notifyDataSetChanged()
        }
    }
    
    func toggleDataSet(sender: UIButton) {
        let dataset = chartDataSets[sender.tag]
        dataset.visible = !dataset.isVisible
        if dataset.isVisible {
            sender.isSelected = true
        } else {
            sender.isSelected = false
        }
        notifyDataSetChanged()
    }
}
