//
//  LocationProvider.swift
//  ProbingPlayground
//
//  Created by Kamil Strzelecki on 07/05/2025.
//  Copyright © 2025 Kamil Strzelecki. All rights reserved.
//

import CoreLocation

protocol LocationProvider {
    func getUpdates() -> any AsyncSequence<any LocationUpdate, any Error>
}

protocol LocationUpdate {
    var location: CLLocation? { get }
    var authorizationDenied: Bool { get }
}

struct SystemLocationProvider: LocationProvider {
    func getUpdates() -> any AsyncSequence<any LocationUpdate, any Error> {
        CLLocationUpdate.liveUpdates().map { $0 as LocationUpdate }
    }
}

extension CLLocationUpdate: LocationUpdate {}
