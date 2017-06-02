//
//  AccelChartView.swift
//  medline
//
//  Created by Bailey Blankenship on 5/25/17.
//  Copyright © 2017 Bailey Blankenship. All rights reserved.
//

import Foundation
import Charts

class AccelChartView : MedlineLineChartView {
    public var holding : Bool = false
    
    var accelXEntries : [ChartDataEntry] = []
    var accelYEntries : [ChartDataEntry] = []
    var accelZEntries : [ChartDataEntry] = []
    
    var accelXDataSet : LineChartDataSet!
    var accelYDataSet : LineChartDataSet!
    var accelZDataSet : LineChartDataSet!
    
    var chartData : ChartData!
    var chartDataSets : [LineChartDataSet]!
    
    let chartColors : [UIColor] = [.pink, .yellow, .green]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initChart()
    }
    
    func initChart(){
        accelXDataSet = LineChartDataSet(values: accelXEntries, label: "X")
        accelYDataSet = LineChartDataSet(values: accelYEntries, label: "Y")
        accelZDataSet = LineChartDataSet(values: accelZEntries, label: "Z")
        
        chartDataSets = [accelXDataSet, accelYDataSet, accelZDataSet]
        
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
    
    func alphaAddToGraph(packet: Data, date: Date, range: Int?){
        let signed_data = packet.map { Int8(bitPattern: $0) }

        let x = Int(signed_data[3])
        let y = Int(signed_data[4])
        let z = Int(signed_data[5])
        
        addToGraph(x: x, y: y, z: z, date: date, range: range)
    }
    
    func betaAddToGraph(packet: Data, date: Date, range: Int?){
        let signed_data = packet.map { Int8(bitPattern: $0) }
        
        let x = Int(signed_data[12])
        let y = Int(signed_data[14])
        let z = Int(signed_data[16])
        
        addToGraph(x: x, y: y, z: z, date: date, range: range)
    }
    
    func addToGraph(x: Int, y: Int, z: Int, date: Date, range: Int?){
        let timestamp = date.timeIntervalSince1970
        
        let xEntry = ChartDataEntry(x: timestamp, y: Double(x))
        let yEntry = ChartDataEntry(x: timestamp, y: Double(y))
        let zEntry = ChartDataEntry(x: timestamp, y: Double(z))
        
        if let range = range {
            if (lineData?.dataSets[0].entryCount)! > range {
                let first = lineData?.dataSets[0].entryForIndex(0)
                xAxis.axisMinimum = (first?.x)!
                
                _ = lineData?.dataSets[0].removeFirst()
                _ = lineData?.dataSets[1].removeFirst()
                _ = lineData?.dataSets[2].removeFirst()
            }
        }
        
        data?.addEntry(xEntry, dataSetIndex: 0)
        data?.addEntry(yEntry, dataSetIndex: 1)
        data?.addEntry(zEntry, dataSetIndex: 2)
        
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
