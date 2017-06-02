//
//  MedlineLineChartView.swift
//  medline
//
//  Created by Bailey Blankenship on 5/24/17.
//  Copyright © 2017 Bailey Blankenship. All rights reserved.
//

import UIKit
import Charts

class MedlineLineChartView: LineChartView {
    override func awakeFromNib() {
        xAxis.labelPosition = .bottom
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = false
        xAxis.labelTextColor = .primary
        rightAxis.enabled = false
        rightAxis.drawGridLinesEnabled = false
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawAxisLineEnabled = false
        leftAxis.labelTextColor = .primary
        leftAxis.drawGridLinesEnabled = false
        chartDescription?.enabled = false
        drawBordersEnabled = false

    }
}

