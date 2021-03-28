//
//  ViewController.swift
//  HRMTesterNew
//
//  Created by Allen Liang on 8/22/20.
//  Copyright © 2020 Allen Liang. All rights reserved.
//

import UIKit
import CoreBluetooth
import Charts

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        centralManager = CBCentralManager(delegate: self, queue: nil)
        setupView()
        listVC.viewControllerDelegate = self
        
//        Notificationenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
//    @objc func appMovedToBackground() {
//        backgroundTimeLimitTimer = Timer.scheduledTimer(timeInterval: 10800.0, target: self, selector: #selector(handleAppBeingTerminated), userInfo: nil, repeats: false)
//    }
    
    @objc func handleAppBeingTerminated() {
        if let firstHRM = firstHRM {
            centralManager.cancelPeripheralConnection(firstHRM)
        }
        if let secondHRM = secondHRM {
            centralManager.cancelPeripheralConnection(secondHRM)
        }
        print("handleAPPBINGETMINATED CALLED")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        listVC.view.isHidden = true
    }
    
    var centralManager: CBCentralManager!
    var backgroundTimeLimitTimer: Timer?
    
    
    
    //=======CHARTS=================================================
    lazy var lineChart: LineChartView = {
        let chart = LineChartView()
        chart.rightAxis.enabled = false
        
        let yAxis = chart.leftAxis
        yAxis.setLabelCount(6, force: false)
        yAxis.labelPosition = .outsideChart
        
        chart.xAxis.labelPosition = .bottom
        
        return chart
    }()
    
    
    
    func setData() {
        let firstIndex = firstHRM?.name?.firstIndex(of: " ")
        let secondIndex = secondHRM?.name?.firstIndex(of: " ")
        
        let firstName = firstHRM?.name
        let secondName = secondHRM?.name
        
        let set1 = LineChartDataSet(entries: firstEntries, label: String(firstName![..<firstIndex!]))
        let set2 = LineChartDataSet(entries: secondEntries, label: String(secondName![..<secondIndex!]))
        
        set1.lineWidth = 2
//        set1.mode = .cubicBezier
        set1.setColor(.red)
        set1.drawCirclesEnabled = false
        
        set2.lineWidth = 2
//        set2.mode = .cubicBezier
        set2.setColor(.cyan)
        set2.drawCirclesEnabled = false
        
        let data = LineChartData(dataSets: [set1, set2])
        
        
        data.setDrawValues(false)
        lineChart.data = data
    }
    
    var firstHRM: CBPeripheral? {
        didSet {
            if let deviceName = firstHRM?.name {
                let index = deviceName.firstIndex(of: " ") ?? deviceName.endIndex
                firstHRMLabel.text = String(deviceName[..<index])
            }
        }
    }
    
    var secondHRM: CBPeripheral? {
        didSet {
            if let deviceName = secondHRM?.name {
                let index = deviceName.firstIndex(of: " ") ?? deviceName.endIndex
                secondHRMLabel.text = String(deviceName[..<index])
            }
        }
    }
    
    let heartRateServiceCBUUID = CBUUID(string: "0x180D")
    let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: "2A37")
    
    let listVC = PeripheralListController()
    var firstHR = 0
    var secondHR = 0
    var time = 0
    var dataTimer: Timer?
    var firstEntries = [ChartDataEntry]()
    var secondEntries = [ChartDataEntry]()
    var isPaused = false
    
    var sum = 0
    
    let firstHRMLabel: UILabel = {
        let lb = UILabel(text: "First HRM", font: .boldSystemFont(ofSize: 26))
        lb.textAlignment = .center
        return lb
    }()
    
    let firstHRLabel: UILabel = {
        let lb = UILabel(text: "0", font: .boldSystemFont(ofSize: 70))
        lb.textAlignment = .center
        return lb
    }()
    
    let secondHRMLabel: UILabel = {
        let lb = UILabel(text: "Second HRM", font: .boldSystemFont(ofSize: 26))
        lb.textAlignment = .center
        return lb
    }()
    let secondHRLabel: UILabel = {
        let lb = UILabel(text: "0", font: .boldSystemFont(ofSize: 70))
        lb.textAlignment = .center
        return lb
    }()
    
    let firstScanButton: UIButton = {
        let button = UIButton(title: "Connect")
        button.addTarget(self, action: #selector(handleFirstScanButtonPress), for: .touchUpInside)
        return button
    }()
    
    let secondScanButton: UIButton = {
        let button = UIButton(title: "Connect")
        button.addTarget(self, action: #selector(handleSecondScanButtonPress), for: .touchUpInside)
        return button
    }()
    
    let firstDisconnectButton: UIButton = {
        let button = UIButton(title: "Disconnect")
        button.addTarget(self, action: #selector(handleFirstDisconnectButtonPress), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    let secondDisconnectButton: UIButton = {
        let button = UIButton(title: "Disconnect")
        button.addTarget(self, action: #selector(handleSecondDisconnectButtonPress), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    let startButton: UIButton = {
        let button = UIButton(title: "Start")
        button.addTarget(self, action: #selector(startCollectingData), for: .touchUpInside)
        return button
    }()
    
    let endButton: UIButton = {
        let button = UIButton(title: "End")
        button.isHidden = true
        button.setTitleColor(.red, for: .normal)
        button.addTarget(self, action: #selector(endButtonPressed), for: .touchUpInside)
        return button
    }()
    
    let hrDifferenceLabel: UILabel = {
        let lb = UILabel(text: "0", font: .boldSystemFont(ofSize: 30))
        lb.textAlignment = .center
        lb.isHidden = true
        return lb
    }()
    
    let avgHrDifferenceLabel: UILabel = {
        let lb = UILabel(text: "0", font: .systemFont(ofSize: 20))
        lb.textAlignment = .center
        return lb
    }()
    
    @objc func endButtonPressed() {
        firstEntries = [ChartDataEntry]()
        secondEntries = [ChartDataEntry]()
        time = 0
        endButton.isHidden = true
        startButton.setTitle("Start", for: .normal)
        firstDisconnectButton.isHidden = false
        secondDisconnectButton.isHidden = false
        hrDifferenceLabel.isHidden = true
    }
    
    @objc func startCollectingData() {
        if firstHRM != nil && secondHRM != nil {
            if isPaused {
                endButton.isHidden = true
            }
            hrDifferenceLabel.isHidden = false
            stopButton.isHidden = false
            firstDisconnectButton.isHidden = true
            secondDisconnectButton.isHidden = true
            startButton.isHidden = true
            dataTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(addDataEntry), userInfo: nil, repeats: true)
        } else {
            let alertController = UIAlertController(title: "Connect both heart rate monitors", message: nil, preferredStyle: .alert)
            let action1 = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(action1)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func stopButtonPressed() {
        isPaused = true
        dataTimer?.invalidate()
        stopButton.isHidden = true
        startButton.isHidden = false
        startButton.setTitle("Resume", for: .normal)
        endButton.isHidden = false
        
        var firstSum = 0.0
        for i in firstEntries {
            firstSum += i.y
        }
        
        var secondSum = 0.0
        for i in secondEntries {
            secondSum += i.y
        }
        
        let avg1 = firstSum/Double(time)
        let avg2 = secondSum/Double(time)
        
        print(avg1-avg2)
    }
    
    @objc func addDataEntry() {
        time += 1
        let difference = firstHR - secondHR
        sum += difference
        
        if difference >= 8 || difference <= -8 {
            hrDifferenceLabel.textColor = .red
        } else if difference >= 5 || difference <= -5 {
            hrDifferenceLabel.textColor = .black
        } else {
            hrDifferenceLabel.textColor = .green
        }
        hrDifferenceLabel.text = "\(difference)"
//        avgHrDifferenceLabel.text = "\(Int(sum/time))"
        firstEntries.append(ChartDataEntry(x: Double(time), y: Double(firstHR)))
        secondEntries.append(ChartDataEntry(x: Double(time), y: Double(secondHR)))
        setData()
    }
    
    let stopButton: UIButton = {
        let button = UIButton(title: "Stop")
        button.isHidden = true
        button.addTarget(self, action: #selector(stopButtonPressed), for: .touchUpInside)
        return button
    }()
    
    @objc func handleFirstScanButtonPress() {
        listVC.list.removeAll()
        listVC.deviceNumber = 1
        if centralManager.state == .poweredOn {
            showList()
            centralManager.scanForPeripherals(withServices: [heartRateServiceCBUUID])
        } else {
            print("central not on")
        }
    }
    
    @objc func handleSecondScanButtonPress() {
        listVC.list.removeAll()
        listVC.deviceNumber = 2
        if centralManager.state == .poweredOn {
            showList()
            centralManager.scanForPeripherals(withServices: [heartRateServiceCBUUID])
        } else {
            print("central not on")
        }
    }
    
    @objc func handleFirstDisconnectButtonPress() {
        print("hello")
        guard let device = firstHRM else { return }
        centralManager.cancelPeripheralConnection(device)
        firstHRM = nil

        firstHRMLabel.text = "First HRM"
        firstHRLabel.text = "0"
        firstDisconnectButton.isHidden = true
        firstScanButton.isHidden = false
        
    }
    
    @objc func handleSecondDisconnectButtonPress() {
        guard let device = secondHRM else { return }
        centralManager.cancelPeripheralConnection(device)
        secondHRM = nil
        secondHRMLabel.text = "Second HRM"
        secondHRLabel.text = "0"
        secondDisconnectButton.isHidden = true
        secondScanButton.isHidden = false
    }
    
    func connectToPeripheral(device: CBPeripheral) {
        print("connecting")
        centralManager.connect(device)
        centralManager.stopScan()
        hideList()
    }
    
    func hideList() {
        listVC.view.isHidden = true
        centralManager.stopScan()
        
        startButton.isEnabled = true
        stopButton.isEnabled = true
    }
    
    func showList() {
        listVC.view.isHidden = false
        listVC.tableView.reloadData()
        startButton.isEnabled = false
        stopButton.isEnabled = false
    }
    
    func setupView() {
        
        let firstStack = VerticalStackView(arrangedSubviews: [firstHRMLabel, firstHRLabel, firstScanButton, firstDisconnectButton], spacing: 12)
        firstStack.distribution = .fillProportionally
        
        let secondStack = VerticalStackView(arrangedSubviews: [secondHRMLabel, secondHRLabel, secondScanButton, secondDisconnectButton], spacing: 12)
        secondStack.distribution = .fillProportionally
        
        let hrStacks = UIStackView(arrangedSubviews: [firstStack, secondStack], customSpacing: 20)
        hrStacks.distribution = .fillEqually
        
        view.addSubview(hrStacks)
        
        hrStacks.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 20, left: 20, bottom: 0, right: 20))

        view.addSubview(lineChart)

        lineChart.anchor(top: hrStacks.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 80, right: 0))
        lineChart.centerXInSuperview()
        
        view.addSubview(hrDifferenceLabel)
        view.addSubview(avgHrDifferenceLabel)
        
        hrDifferenceLabel.centerXInSuperview()
        hrDifferenceLabel.centerYAnchor.constraint(equalTo: firstHRLabel.centerYAnchor).isActive = true
        
//        avgHrDifferenceLabel.anchor(top: hrDifferenceLabel.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 8, left: 0, bottom: 0, right: 0))
//        avgHrDifferenceLabel.centerXInSuperview()
        
        view.addSubview(startButton)
        view.addSubview(stopButton)
        view.addSubview(endButton)
        
        startButton.anchor(top: nil, leading: nil, bottom: view.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 30, right: 0))
        startButton.centerXInSuperview()
        
        stopButton.anchor(top: nil, leading: nil, bottom: view.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 30, right: 0))
        stopButton.centerXInSuperview()
        
        endButton.anchor(top: nil, leading: nil, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 30, right: 20))
        
        addChild(listVC)
        view.addSubview(listVC.view)
        listVC.view.centerInSuperview()
        listVC.view.constrainWidth(constant: 300)
        listVC.view.constrainHeight(constant: 400)
        listVC.view.layer.borderWidth = 1
        listVC.view.layer.borderColor = UIColor.black.cgColor
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view != listVC.view {
            hideList()
        }
    }
    
    func updateFirstHR(bpm: Int) {
        if bpm > 20 {
            firstHRLabel.text = "\(bpm)"
            firstHR = bpm
        }
    }
    
    func updateSecondHR(bpm: Int) {
        if bpm > 20 {
            secondHRLabel.text = "\(bpm)"
            secondHR = bpm
        }
    }
    
}

extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            
        case .unknown:
            print("State unknown")
        case .resetting:
            print("State resetting")
        case .unsupported:
            print("State unsupported")
        case .unauthorized:
            print("State unauthorized")
        case .poweredOff:
            print("State powered Off")
        case .poweredOn:
            print("State powered On")
        @unknown default:
            print("State default")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name  != firstHRM?.name && peripheral.name != secondHRM?.name {
            print(peripheral)
            listVC.list.append(peripheral)
            listVC.tableView.reloadData()
        } else {
            print("hello")
        }
    }
    
    
}

extension ViewController: CBPeripheralDelegate {
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard let peripheralName = peripheral.name else { return }
        print("connected to \(peripheralName)")
        print(peripheral)
        if firstHRM != nil {
            firstScanButton.isHidden = true
            firstDisconnectButton.isHidden = false
        }
        if secondHRM != nil {
            secondScanButton.isHidden = true
            secondDisconnectButton.isHidden = false
        }
        peripheral.delegate = self
        peripheral.discoverServices([heartRateServiceCBUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print(characteristic)
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch peripheral {
        case firstHRM:
            heartRate(from: characteristic)
        case secondHRM:
            secondHeartRate(from: characteristic)
        default:
            print("default")
        }
    }
    
    private func heartRate(from characteristic: CBCharacteristic){
        guard let characteristicData = characteristic.value else { return }
        let byteArray = [UInt8](characteristicData)
        var hr = 0
        let hrFormat = byteArray[0] & 0x01;
        let rrPresent = (byteArray[0] & 0x10) >> 4;
        let energyExpended = (byteArray[0] & 0x08) >> 3;
        var offset = Int(hrFormat) + 2;
        var energy = 0
        
        if (energyExpended == 1) {
          energy = Int(byteArray[offset]) + (Int(byteArray[offset + 1]) << 8);
          offset += 2;
        }
        
        var rrs = [Int]()
        if( rrPresent == 1 ){
          let len = byteArray.count
          while (offset < len) {
            let rrValueRaw = Int(byteArray[offset]) | (Int(byteArray[offset + 1]) << 8)
            let rrValue = Int((Double(rrValueRaw) / 1024.0) * 1000.0);
            offset += 2;
            rrs.append(rrValue);
          }
        }
        
        let firstBitValue = byteArray[0] & 0x01
        if firstBitValue == 0 {
            hr = Int(byteArray[1])
        } else {
            hr = (Int(byteArray[1]) << 8) + Int(byteArray[2])
        }
        
        updateFirstHR(bpm: hr)
        
    }
    
    private func secondHeartRate(from characteristic: CBCharacteristic){
        guard let characteristicData = characteristic.value else { return }
        let byteArray = [UInt8](characteristicData)
        var hr = 0
        let hrFormat = byteArray[0] & 0x01;
        let rrPresent = (byteArray[0] & 0x10) >> 4;
        let energyExpended = (byteArray[0] & 0x08) >> 3;
        var offset = Int(hrFormat) + 2;
        var energy = 0
        
        if (energyExpended == 1) {
          energy = Int(byteArray[offset]) + (Int(byteArray[offset + 1]) << 8);
          offset += 2;
        }
        
        var rrs = [Int]()
        if( rrPresent == 1 ){
          let len = byteArray.count
          while (offset < len) {
            let rrValueRaw = Int(byteArray[offset]) | (Int(byteArray[offset + 1]) << 8)
            let rrValue = Int((Double(rrValueRaw) / 1024.0) * 1000.0);
            offset += 2;
            rrs.append(rrValue);
          }
        }
        
        let firstBitValue = byteArray[0] & 0x01
        if firstBitValue == 0 {
            hr = Int(byteArray[1])
        } else {
            hr = (Int(byteArray[1]) << 8) + Int(byteArray[2])
        }
        
        updateSecondHR(bpm: hr)
    }
}
