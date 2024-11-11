//
//  BluetoothScanner.swift
//  bluby
//
//  Created by Tom Pickard on 11/10/24.
//
import CoreBluetooth
import CoreLocation

class BluetoothScanner: NSObject, CBCentralManagerDelegate, CLLocationManagerDelegate {
    private var centralManager: CBCentralManager!
    private var locationManager = CLLocationManager()
    private(set) var detectedDevices = [UUID: DetectedDevice]()
    
    private let userDefaultsKey = "DetectedDevices" // Key for UserDefaults storage
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        // Load previously detected devices from UserDefaults
        loadDetectedDevices()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        } else {
            print("Bluetooth is not available or is turned off.")
        }
    }
    
    func startScanning() {
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let deviceUUID = peripheral.identifier
        let deviceName = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "Unknown Device"
        let proximity = calculateProximity(rssi: RSSI.intValue)
        let location = locationManager.location
        
        if var device = detectedDevices[deviceUUID] {
            // Update last seen, proximity, name, and location if the device already exists
            device.lastSeen = Date()
            device.proximity = proximity
            device.name = deviceName
            device.latitude = location?.coordinate.latitude
            device.longitude = location?.coordinate.longitude
            detectedDevices[deviceUUID] = device
        } else {
            // New device detected, add it to the list
            let newDevice = DetectedDevice(uuid: deviceUUID, name: deviceName, firstSeen: Date(), lastSeen: Date(), proximity: proximity, latitude: location?.coordinate.latitude ?? 0.0, longitude: location?.coordinate.longitude ?? 0.0)
            detectedDevices[deviceUUID] = newDevice
        }
        
        // Save updated device list to UserDefaults
        saveDetectedDevices()
        
        // Notify listeners that the device list has been updated
        NotificationCenter.default.post(name: .deviceListUpdated, object: nil)
    }
    
    func calculateProximity(rssi: Int) -> String {
        switch rssi {
        case -60...0:
            return "Near"
        case -90..<(-60):
            return "Moderate"
        default:
            return "Far"
        }
    }
    
    private func saveDetectedDevices() {
        // Convert the dictionary values (devices) to an array
        let devicesArray = Array(detectedDevices.values)
        do {
            let data = try JSONEncoder().encode(devicesArray)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Failed to save devices: \(error)")
        }
    }
    
    private func loadDetectedDevices() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }
        do {
            let devicesArray = try JSONDecoder().decode([DetectedDevice].self, from: data)
            // Rebuild the dictionary from the loaded array
            detectedDevices = Dictionary(uniqueKeysWithValues: devicesArray.map { ($0.uuid, $0) })
        } catch {
            print("Failed to load devices: \(error)")
        }
    }
}
/*
import CoreBluetooth
import CoreLocation

class BluetoothScanner: NSObject, CBCentralManagerDelegate, CLLocationManagerDelegate {
    private var centralManager: CBCentralManager!
    private var locationManager = CLLocationManager()
    private(set) var detectedDevices = [UUID: DetectedDevice]()
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        } else {
            print("Bluetooth is not available or is turned off.")
        }
    }
    
    func startScanning() {
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let deviceUUID = peripheral.identifier
        let deviceName = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "Unknown Device"
        let proximity = calculateProximity(rssi: RSSI.intValue)
        let location = locationManager.location
        
        if var device = detectedDevices[deviceUUID] {
            // Update last seen, proximity, name, and location if the device already exists
            device.lastSeen = Date()
            device.proximity = proximity
            device.name = deviceName
            device.location = location
            detectedDevices[deviceUUID] = device
        } else {
            // New device detected, add it to the list
            let newDevice = DetectedDevice(uuid: deviceUUID, name: deviceName, firstSeen: Date(), lastSeen: Date(), proximity: proximity, location: location)
            detectedDevices[deviceUUID] = newDevice
        }
        
        // Notify listeners that the device list has been updated
        NotificationCenter.default.post(name: .deviceListUpdated, object: nil)
    }
    
    func calculateProximity(rssi: Int) -> String {
        switch rssi {
        case -60...0:
            return "Near"
        case -90..<(-60):
            return "Moderate"
        default:
            return "Far"
        }
    }
}
*/
