//
//  PeripheralListTableViewController.swift
//  BluetoothPracticeWhoop
//
//  Created by Allen on 3/18/20.
//  Copyright © 2020 Allen. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralListController: UITableViewController {

    var list = [CBPeripheral]()
    let cellId = "cellId"
    var viewControllerDelegate: ViewController?
    var deviceNumber: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(DeviceCell.self, forCellReuseIdentifier: cellId)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! DeviceCell
        cell.device = list[indexPath.row]
        cell.backgroundColor = .white
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if deviceNumber == 1 {
            viewControllerDelegate?.firstHRM = list[indexPath.row]
        } else {
            viewControllerDelegate?.secondHRM = list[indexPath.row]
        }
        viewControllerDelegate?.connectToPeripheral(device: list[indexPath.row])
    }

}


class DeviceCell: UITableViewCell {
    
    var device: CBPeripheral? {
        didSet {
            if let deviceName = device?.name {
                deviceLabel.text = deviceName
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let deviceLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "placeholder"
        lb.textColor = .black
        lb.textAlignment = .center
        return lb
    }()
    
    func setupView() {
        addSubview(deviceLabel)
        
        deviceLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        deviceLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        deviceLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        deviceLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
    }
}
