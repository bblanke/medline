//
//  RecordDelegate.swift
//  medline
//
//  Created by Bailey Blankenship on 5/25/17.
//  Copyright © 2017 Bailey Blankenship. All rights reserved.
//

import Foundation
import CoreData

protocol RecordDelegate: class {
    func didSelectAlphaReading(reading : AlphaReading)
    func didSelectBetaReading(reading: BetaReading)
}
