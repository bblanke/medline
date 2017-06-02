//
//  ChartsViewController.swift
//  medline
//
//  Created by Bailey Blankenship on 5/15/17.
//  Copyright © 2017 Bailey Blankenship. All rights reserved.
//

import UIKit
import CoreBluetooth
import Charts

class ChartsViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    // MARK: - Globals
    
    // Bluetooth Variables
    var manager : CBCentralManager!
    var connectedPeripheral : CBPeripheral!
    var deviceType : DeviceType!
    
    enum DeviceType {
        case alpha, beta
    }
    
    // Bluetooth Constants
    let medlineServiceUUID = CBUUID(string: "FFF0")
    let enableCharacteristicUUID = CBUUID(string: "FFF1")
    let betaEegCharacteristicUUID = CBUUID(string: "FFF2")
    let alphaPulseOxCharacteristicUUID = CBUUID(string: "FFF3")
    let alphaBattAccelCharacteristicUUID = CBUUID(string: "FFF4")
    
    let enableByte = Data(bytes: [1])

    
    // UI Connections

    @IBOutlet weak var pulseOxChartView: PulseOxChartView!
    @IBOutlet weak var accelChartView: AccelChartView!
    @IBOutlet weak var eegChartView: EegChartView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    // Charts
    let topChartSize = 200
    let bottomChartSize = 22 //should be topChartSize/9
    
    // Chart State
    var isRecording = false
    var chartState : ChartState = .disabled
    
    enum ChartState {
        case disabled, bluetoothGraphing, fileGraphing
    }
    
    // Persistence
    var tempPayloadPackets : [Data] = []
    var tempPayloadPacketTimestamps : [Date] = []
    
    var tempAccelPackets : [Data] = []
    var tempAccelPacketTimestamps : [Date] = []
    
    var chartDelegate : ChartDelegate!
    
    // MARK: - View State
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()

        manager = CBCentralManager(delegate: self, queue: nil)
        
        // Set up the visuals
        self.view.layer.cornerRadius = 5.0
        self.view.layer.masksToBounds = true
        self.view.backgroundColor = UIColor.light
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Bluetooth
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("[DEBUG]: Bluetooth manager is up in charts view")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("[DEBUG]: Discovered peripheral services")
        peripheral.discoverCharacteristics([enableCharacteristicUUID, alphaPulseOxCharacteristicUUID, alphaBattAccelCharacteristicUUID, betaEegCharacteristicUUID], for: (peripheral.services?.first)!)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("[DEBUG]: Discovered peripheral characteristics")
        for characteristic in service.characteristics! {
            if characteristic.uuid == enableCharacteristicUUID {
                print("[DEBUG]: Enabling Data Streaming")
                peripheral.writeValue(enableByte, for: characteristic, type: .withResponse)
            } else if characteristic.uuid == alphaPulseOxCharacteristicUUID || characteristic.uuid == alphaBattAccelCharacteristicUUID {
                print("[DEBUG]: Subscribing to Data Stream for characteristic \(characteristic.uuid.uuidString) notify \(characteristic.properties.contains(.notify))")
                peripheral.setNotifyValue(true, for: characteristic)
            } else if characteristic.uuid == betaEegCharacteristicUUID {
                if characteristic.properties.contains(.notify) {
                    peripheral.setNotifyValue(true, for: characteristic)
                    deviceType = .beta
                    pulseOxChartView.isHidden = true
                    eegChartView.isHidden = false
                } else {
                    deviceType = .alpha
                    eegChartView.isHidden = true
                    pulseOxChartView.isHidden = false
                }
                print("[DEBUG]: Subscribing to Data Stream for characteristic \(characteristic.uuid.uuidString) notify \(characteristic.properties.contains(.notify))")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == alphaPulseOxCharacteristicUUID {
            pulseOxChartView.addToGraph(packet: characteristic.value!, date: Date(), range: 200)
            if isRecording {
                tempPayloadPackets.append(characteristic.value!)
                tempPayloadPacketTimestamps.append(Date())
            }
        } else if characteristic.uuid == alphaBattAccelCharacteristicUUID {
            accelChartView.alphaAddToGraph(packet: characteristic.value!, date: Date(), range: (200/9))
            if isRecording {
                tempAccelPackets.append(characteristic.value!)
                tempAccelPacketTimestamps.append(Date())
            }
        } else if characteristic.uuid == betaEegCharacteristicUUID {
            eegChartView.addToGraph(packet: characteristic.value!, date: Date(), range: 200)
            accelChartView.betaAddToGraph(packet: characteristic.value!, date: Date(), range: (200))
        }
    }
    
    
    
    // MARK: - Graphing
    
    func didSelectDevice(device: CBPeripheral){
        pulseOxChartView.initChart()
        accelChartView.initChart()

        blurView.fadeOut()
        chartState = .bluetoothGraphing
        print("[DEBUG]: Beginning graphing process")
        device.delegate = self
        device.discoverServices([medlineServiceUUID])
        connectedPeripheral = device
        
        tempPayloadPackets = []
        tempPayloadPacketTimestamps = []
        
        tempAccelPackets = []
        tempAccelPacketTimestamps = []
    }
    
    func didSelectAlphaReading(reading: AlphaReading){
        switch chartState {
        case .disabled:
            blurView.fadeOut() //remove blur view
            break
        case .bluetoothGraphing:
            manager.cancelPeripheralConnection(connectedPeripheral) //disconnect from a peripheral if connected
            break
        default:
            break
        }
        
        chartState = .fileGraphing
        
        pulseOxChartView.xAxis.resetCustomAxisMin()
        accelChartView.xAxis.resetCustomAxisMin()
        
        pulseOxChartView.initChart()
        accelChartView.initChart()
        
        
        let payloadPackets = Array(reading.pulseOxPackets!) as! [AlphaPulseOxPacket]
        for packet in payloadPackets {
            print("graphing: \(packet.timestamp!.timeIntervalSince1970)")
            let data = packet.data! as Data
            pulseOxChartView.addToGraph(packet: data, date: packet.timestamp! as Date, range: nil)
        }

        let accelPackets = Array(reading.accelPackets!) as! [AlphaAccelPacket]
        for packet in accelPackets {
            let data = packet.data! as Data
            accelChartView.alphaAddToGraph(packet: data, date: packet.timestamp! as Date, range: nil)
        }
    }
    
    // MARK: - Graph Actions
    func setupButtons(){
        let recordButton = ToggleButton(title: "RECORD", color: .warn)
        recordButton.addTarget(self, action: #selector(ChartsViewController.recordClicked), for: .touchUpInside)
        
        let holdButton = ToggleButton(title: "HOLD", color: .primary)
        holdButton.addTarget(self, action: #selector(ChartsViewController.holdClicked), for: .touchUpInside)
        
        let recordButtonItem = UIBarButtonItem(customView: recordButton)
        let holdButtonItem = UIBarButtonItem(customView: holdButton)
        let flexibleSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        var buttonArray = [recordButtonItem, holdButtonItem, flexibleSpaceItem]
        
        for (index, set) in pulseOxChartView.chartDataSets.enumerated() {
            let button = ToggleButton(title: set.label!, color: set.colors.first!)
            button.addTarget(pulseOxChartView, action: #selector(PulseOxChartView.toggleDataSet), for: .touchUpInside)
            button.tag = index
            button.isSelected = true
            let barButton = UIBarButtonItem(customView: button)
            buttonArray.append(barButton)
        }
        
        for (index, set) in accelChartView.chartDataSets.enumerated() {
            let button = ToggleButton(title: set.label!, color: set.colors.first!)
            button.addTarget(accelChartView, action: #selector(AccelChartView.toggleDataSet), for: .touchUpInside)
            button.tag = index
            button.isSelected = true
            let barButton = UIBarButtonItem(customView: button)
            buttonArray.append(barButton)
        }
        
        toolbar.setItems(buttonArray, animated: true)
    }
    
    func holdClicked(sender: UIButton) {
        pulseOxChartView.holding = !pulseOxChartView.holding
        if pulseOxChartView.holding {
            sender.isSelected = true
        } else {
            sender.isSelected = false
        }
    }
    
    func recordClicked(sender: UIButton) {
        isRecording = !isRecording
        if isRecording {
            sender.isSelected = true
            
        } else {
            sender.isSelected = false
            persistAlphaReading()
        }
    }
    
    // MARK: - Persistence
    
    func persistAlphaReading(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let alphaReading = AlphaReading(context: context)
        
        pulseOxChartView.holding = true
        accelChartView.holding = true
        
        let alert = UIAlertController(title: "File Name", message: "Please choose a name describing this recording", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = "Short Name"
        }
        
        alert.addAction(UIAlertAction(title: "SAVE", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            
            alphaReading.shortName = textField?.text
            alphaReading.timestamp = Date() as NSDate
            
            for (index, data) in self.tempPayloadPackets.enumerated() {
                let packet = AlphaPulseOxPacket(context: context)
                packet.data = data as NSData
                packet.timestamp = self.tempPayloadPacketTimestamps[index] as NSDate
                alphaReading.addToPulseOxPackets(packet)
            }
            
            self.tempPayloadPackets = []
            self.tempPayloadPacketTimestamps = []
            
            for (index, data) in self.tempAccelPackets.enumerated() {
                let packet = AlphaAccelPacket(context: context)
                packet.data = data as NSData
                packet.timestamp = self.tempAccelPacketTimestamps[index] as NSDate
                print("trying to add timestamp: \(self.tempAccelPacketTimestamps[index].timeIntervalSince1970)")
                alphaReading.addToAccelPackets(packet)
            }
            
            self.tempAccelPackets = []
            self.tempAccelPacketTimestamps = []
            
            for packet in Array(alphaReading.accelPackets!) as! [AlphaAccelPacket]{
                print("added accel: \(packet.timestamp!.timeIntervalSince1970)")
            }
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            self.pulseOxChartView.holding = false
            self.accelChartView.holding = false
            self.chartDelegate.didSaveRecord()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
