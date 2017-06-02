//
//  ViewController.swift
//  medline
//
//  Created by Bailey Blankenship on 5/15/17.
//  Copyright © 2017 Bailey Blankenship. All rights reserved.
//

import UIKit
import CoreBluetooth

class MasterViewController: GradientView {

    // MARK: - Globals
    var chartsViewController : ChartsViewController!
    var recordsViewController : RecordsViewController!
    var devicesViewController : DevicesViewController!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "masterDevicesSegue" {
            devicesViewController = segue.destination as! DevicesViewController
            devicesViewController.deviceDelegate = self
        } else if segue.identifier == "masterChartsSegue"{
            chartsViewController = segue.destination as! ChartsViewController
            chartsViewController.chartDelegate = self
        } else if segue.identifier == "masterRecordsSegue" {
            recordsViewController = segue.destination as! RecordsViewController
            recordsViewController.recordDelegate = self
        }
        
    }
}

extension MasterViewController : DeviceDelegate {
    func setDeviceConnected(device: CBPeripheral) {
        chartsViewController.didSelectDevice(device: device)
        recordsViewController.selected = nil
        recordsViewController.tableView.reloadData()
    }
}

extension MasterViewController : RecordDelegate {
    func didSelectAlphaReading(reading: AlphaReading) {
        chartsViewController.didSelectAlphaReading(reading: reading)
        devicesViewController.tableView.reloadData()
    }
}

extension MasterViewController : ChartDelegate {
    func didSaveRecord() {
        recordsViewController.loadReadings()
    }
}
