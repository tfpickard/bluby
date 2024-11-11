//
//  DetectedDevice.swift
//  bluby
//
//  Created by Tom Pickard on 11/10/24.
//
import Foundation

import CoreLocation
struct DetectedDevice: Codable {
    let uuid: UUID
    var name: String?
    var firstSeen: Date
    var lastSeen: Date
    var proximity: String
    var latitude: Double?       // Store latitude as Double
    var longitude: Double?      // Store longitude as Double

    // Custom initializer to handle location coordinates
    init(uuid: UUID, name: String?, firstSeen: Date, lastSeen: Date, proximity: String, latitude: Double, longitude: Double) {
        var location: CLLocation?  // Add this property to store the latest location
        self.uuid = uuid
        self.name = name
        self.firstSeen = firstSeen
        self.lastSeen = lastSeen
        self.proximity = proximity
        self.latitude = location?.coordinate.latitude
        self.longitude = location?.coordinate.longitude
    }
}
/*
import Foundation
import CoreLocation

struct DetectedDevice {
    let uuid: UUID
    var name: String?         // Add this property to store the device name
    var firstSeen: Date
    var lastSeen: Date
    var proximity: String
    var location: CLLocation?  // Add this property to store the latest location
}
*/
