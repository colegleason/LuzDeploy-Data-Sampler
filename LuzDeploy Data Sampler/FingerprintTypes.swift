//
//  FingerprintTypes.swift
//  LuzDeploy Data Sampler
//
//  Created by Cole Gleason on 2/17/17.
//  Copyright © 2017 Cole Gleason. All rights reserved.
//

import Foundation
import CoreLocation

struct FingerprintLocation {
    var floor: Int
    var lat: CLLocationDegrees
    var long: CLLocationDegrees
    
    func serialize() -> [String: Any] {
        return ["floor": floor, "lat" : lat, "long": long]
    }
}
// MARK: - Equatable
func ==(lhs: FingerprintLocation, rhs: FingerprintLocation) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
// MARK: - Hashable
extension FingerprintLocation : Hashable {
    public var hashValue : Int {
        get {
            return "(\(self.floor),\(self.lat),\(self.long))".hashValue
        }
    }
}

typealias BeaconSample = (Int, Int) // Minor ID, RSSI

struct Fingerprint {
    var location: FingerprintLocation
    var sample: [BeaconSample]
    
    func serialize() -> [String : Any] {
        return ["sample": sample.map {["bid": $0.0, "rssi": $0.1]},
                "location": location.serialize()] as [String : Any]
    }
}
