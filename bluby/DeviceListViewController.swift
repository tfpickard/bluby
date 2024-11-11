//
//  DeviceListViewController.swift
//  bluby
//
//  Created by Tom Pickard on 11/10/24.
//
import UIKit

class DeviceListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView()
    private let bluetoothScanner = BluetoothScanner()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Nearby Devices"
        setupTableView()
        NotificationCenter.default.addObserver(self, selector: #selector(updateDeviceList), name: .deviceListUpdated, object: nil)
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DeviceCell")
        tableView.frame = view.bounds
        view.addSubview(tableView)
    }

    @objc private func updateDeviceList() {
        tableView.reloadData()
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bluetoothScanner.detectedDevices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create a cell with .subtitle style to ensure detailTextLabel is available
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "DeviceCell")
        let device = Array(bluetoothScanner.detectedDevices.values)[indexPath.row]

        // Set the device name if available, otherwise show "Unknown Device"
        let deviceName = device.name ?? "Unknown Device"
        cell.textLabel?.text = "Device: \(deviceName)"
        
        // Display proximity, last seen, and location (if available)
        var detailText = "Proximity: \(device.proximity), Last seen: \(device.lastSeen)"
        if let latitude = device.latitude, let longitude = device.longitude {
            detailText += String(format: "\nLocation: %.4f, %.4f", latitude, longitude)
        }
        cell.detailTextLabel?.text = detailText
        
        // Set cell background color based on time since first seen
        let timeSinceFirstSeen = Date().timeIntervalSince(device.firstSeen)
        cell.backgroundColor = timeSinceFirstSeen < 60 ? .green : .blue
        
        // Increase cell height by setting text label's number of lines
        cell.textLabel?.numberOfLines = 2
        cell.detailTextLabel?.numberOfLines = 3

        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100 // Increase the cell height as needed
    }
}
