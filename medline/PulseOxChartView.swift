//
//  PulseOxChart.swift
//  medline
//
//  Created by Bailey Blankenship on 5/25/17.
//  Copyright © 2017 Bailey Blankenship. All rights reserved.
//

import Foundation
import Charts

class PulseOxChartView : MedlineLineChartView {
    
    public var holding : Bool = false
    
    var waveOneEntries : [ChartDataEntry] = []
    var waveTwoEntries : [ChartDataEntry] = []
    var waveThreeEntries : [ChartDataEntry] = []
    var skinTempEntries : [ChartDataEntry] = []

    var waveOneDataSet : LineChartDataSet!
    var waveTwoDataSet : LineChartDataSet!
    var waveThreeDataSet : LineChartDataSet!
    var skinTempDataSet : LineChartDataSet!
    
    var chartData : ChartData!
    var chartDataSets : [LineChartDataSet]!
    
    let chartColors : [UIColor] = [.orange, .accent, .purple, .dark]
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        initChart()
    }
    
    func initChart(){
        waveOneDataSet = LineChartDataSet(values: waveOneEntries, label: "W1")
        waveTwoDataSet = LineChartDataSet(values: waveTwoEntries, label: "W2")
        waveThreeDataSet = LineChartDataSet(values: waveThreeEntries, label: "W3")
        skinTempDataSet = LineChartDataSet(values: skinTempEntries, label: "Skin Temp")
        
        chartDataSets = [waveOneDataSet, waveTwoDataSet, waveThreeDataSet, skinTempDataSet]
        
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
        
        let waveOne = (Int(packet[12]) << 8) + (Int(packet[13]))
        let waveTwo = (Int(packet[14]) << 8) + (Int(packet[15]))
        let waveThree = (Int(packet[16]) << 8) + (Int(packet[17]))
        let skinTemp = (Int(packet[18]) << 8) + (Int(packet[19]))
        
        let waveOneEntry = ChartDataEntry(x: timestamp, y: Double(waveOne))
        let waveTwoEntry = ChartDataEntry(x: timestamp, y: Double(waveTwo))
        let waveThreeEntry = ChartDataEntry(x: timestamp, y: Double(waveThree))
        let skinTempEntry = ChartDataEntry(x: timestamp, y: Double(skinTemp))
        
        
        if let range = range {
            if (lineData?.dataSets[0].entryCount)! > range {
                let first = lineData?.dataSets[0].entryForIndex(0)
                
                xAxis.axisMinimum = (first?.x)!
                
                _ = lineData?.dataSets[0].removeFirst()
                _ = lineData?.dataSets[1].removeFirst()
                _ = lineData?.dataSets[2].removeFirst()
                _ = lineData?.dataSets[3].removeFirst()
            }
        }
        
        data?.addEntry(waveOneEntry, dataSetIndex: 0)
        data?.addEntry(waveTwoEntry, dataSetIndex: 1)
        data?.addEntry(waveThreeEntry, dataSetIndex: 2)
        data?.addEntry(skinTempEntry, dataSetIndex: 3)

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
