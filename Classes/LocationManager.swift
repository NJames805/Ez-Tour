//
//  LocationManager.swift
//  Ez Tour
//
//  Created by Nathanael James on 5/14/25.
//
import Foundation
import SwiftUI
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationManager : CLLocationManager?
    @Published var userLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    weak var viewModel: MapViewModel?  // Add 'weak' to prevent retain cycles
    
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
        super.init()
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
    }

    func checkAuthorization() {
        guard let locationManager = locationManager else { return }
        switch locationManager.authorizationStatus {
        case .notDetermined:
            print("Requesting location authorization")
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("Location access denied/restricted")
        case .authorizedAlways, .authorizedWhenInUse:
            print("Location authorized — starting updates")
            locationManager.startUpdatingLocation()
        @unknown default:
            fatalError("Unknown authorization status")
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = latestLocation.coordinate
            self.viewModel?.userLocation = self.userLocation
            print("User location updated: \(self.userLocation) and ViewModel UserLocation = \(self.viewModel?.userLocation ?? self.userLocation)")
        }
    }
}

