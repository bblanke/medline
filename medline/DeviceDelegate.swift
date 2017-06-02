//
//  DeviceDelegate.swift
//  medline
//
//  Created by Bailey Blankenship on 5/15/17.
//  Copyright © 2017 Bailey Blankenship. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol DeviceDelegate: class {
    func setDeviceConnected(device: CBPeripheral)
}
