//
//  DevicesViewController.swift
//  medline
//
//  Created by Bailey Blankenship on 5/15/17.
//  Copyright © 2017 Bailey Blankenship. All rights reserved.
//

import UIKit
import CoreBluetooth

class DevicesViewController: UITableViewController, CBCentralManagerDelegate {
    
    // MARK: - Globals
    
    // Bluetooth Variables
    var manager : CBCentralManager!
    var devices : [CBPeripheral] = []
    weak var deviceDelegate : DeviceDelegate?
    
    // Bluetooth Constants
    let medlineServiceUUID = CBUUID(string: "FFF0")

    
    // MARK: - View State
    
    override func viewDidLoad() {
        super.viewDidLoad()

        manager = CBCentralManager(delegate: self, queue: nil)
        refreshControl?.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
        refreshControl?.tintColor = UIColor.light
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return devices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCell", for: indexPath)
        
        cell.textLabel?.text = devices[indexPath.row].name ?? "Unknown Device"
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor.light
        cell.selectionStyle = .none
        
        if devices[indexPath.row].state == .connected {
            cell.textLabel?.textColor = UIColor.primary
            cell.backgroundColor = UIColor.light
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        for device in manager.retrieveConnectedPeripherals(withServices: [medlineServiceUUID]){ //disconnect all devices before we connect
            if(device.identifier != devices[indexPath.row].identifier){
                manager.cancelPeripheralConnection(device)
            }
        }
        if devices[indexPath.row].state == .disconnected {
            manager.connect(devices[indexPath.row], options: nil)
        }
    }
    
    
    
    // MARK: - Bluetooth
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("[DEBUG]: Bluetooth powered on in devices view")
            central.scanForPeripherals(withServices: [medlineServiceUUID], options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("[DEBUG]: Bluetooth discovered peripheral with uuid: \(peripheral.identifier.uuidString)")
        
        let index = devices.index(where: {$0.identifier == peripheral.identifier})
        
        if index == nil {
            devices.append(peripheral)
        } else {
            devices[index!] = peripheral
        }
        
        tableView.reloadData()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("[DEBUG]: Bluetooth connected to peripheral with uuid: \(peripheral.identifier.uuidString)")
        manager.stopScan()
        deviceDelegate?.setDeviceConnected(device: peripheral)
        tableView.reloadData()
    }
    
    func handleRefresh(refreshControl: UIRefreshControl){
        refreshDevices()
        refreshControl.endRefreshing()
    }
    
    func refreshDevices() {
        devices.removeAll()
        if manager.state == .poweredOn {
            manager.scanForPeripherals(withServices: [medlineServiceUUID], options: nil)
        }
        tableView.reloadData()
    }
    
    
    // MARK: - Visuals

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
