//
//  LocationProvider.swift
//  ProbingPlayground
//
//  Created by Kamil Strzelecki on 07/05/2025.
//  Copyright © 2025 Kamil Strzelecki. All rights reserved.
//

import CoreLocation

protocol LocationProvider {
    associatedtype Updates: AsyncSequence<CLLocationUpdate, any Error>
    func getUpdates() -> Updates
}

struct SystemLocationProvider: LocationProvider {
    func getUpdates() -> CLLocationUpdate.Updates {
        CLLocationUpdate.liveUpdates()
    }
}
