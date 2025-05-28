//
//  MapViewModel.swift
//  Ez Tour
//
//  Created by Nathanael James on 5/14/25.
//

import SwiftUI
import MapKit
import CoreLocation

@MainActor
class MapViewModel: ObservableObject {
    @Published var priceSelected = false
    @Published var isSelectingMarker = false
    @Published var isLoadingMore = false
    @AppStorage("useMiles") var useMiles = false
    @Published var pricelevel: Int? = nil {
        didSet {
            if oldValue != pricelevel {
                fetcher.places = []
                radius = 1500 // Reset radius when price level changes
            }
        }
    }
    @Published var selectedType: String = "" {
        didSet {
            if oldValue != selectedType {
                fetcher.places = []
                radius = 1500 // Reset radius when place type changes
            }
        }
    }
    @Published var typeSelected: Bool = false
    @Published var selectedMarker: String?
    @Published var selectedPlace: Place?
    @Published var radius: Int = 1500
    @Published var showHeart = false
    @Published var isFavorited = false
    @Published var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var locationManager: LocationManager!
    @Published var fetcher = PlaceFetcher()
    
    init() {
        self.locationManager = LocationManager(viewModel: self)
    }

    let placeTypes = [
        "restaurant", "bar", "food", "establishment",
        "cafe", "lodging", "supermarket", "park", "museum"
    ]
    
    func fetchPlacesIfValid() async {
        print("function called")
        if typeSelected && priceSelected {
            await fetcher.fetchNearbyRestaurants(
                priceLevel: pricelevel,
                placeType: selectedType,
                userLocation: userLocation,
                setRadius: radius
            )
        }
    }

    func sortedPlaces() -> [Place] {
        guard let userLocation = userLocation else { return fetcher.places }
        
        let userLoc = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        
        return fetcher.places.sorted { place1, place2 in
            let loc1 = CLLocation(latitude: place1.coordinate.latitude, longitude: place1.coordinate.longitude)
            let loc2 = CLLocation(latitude: place2.coordinate.latitude, longitude: place2.coordinate.longitude)
            return userLoc.distance(from: loc1) < userLoc.distance(from: loc2)
        }
    }

    func handleMarkerSelection(markerID: String) {
        fetcher.markerSelected(markerID: markerID)
        if let place = fetcher.places.first(where: { $0.id == markerID }) {
            selectedPlace = place
            isSelectingMarker = true
            withAnimation {
                position = .region(
                    MKCoordinateRegion(
                        center: place.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                )
            }
        }
    }

    func priceLabel(for level: Int) -> String {
        switch level {
        case 0: return "Free"
        case 1: return "Inexpensive"
        case 2: return "Moderate"
        case 3: return "Expensive"
        case 4: return "Very Expensive"
        default: return "Unknown"
        }
    }

    func openInMaps(destinationLat: Double, destinationLng: Double) {
        let destination = CLLocationCoordinate2D(latitude: destinationLat, longitude: destinationLng)
        let placemark = MKPlacemark(coordinate: destination)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Selected Place"
        mapItem.openInMaps(launchOptions: nil)
    }

    func switchDistanceMeasurement() {
        useMiles.toggle()
    }

    func formatDistance(_ meters: Double) -> String {
        if useMiles {
            let miles = meters * 0.000621371 // Convert meters to miles
            return String(format: "%.1f mi away", miles)
        } else {
            let kilometers = meters / 1000
            return String(format: "%.1f km away", kilometers)
        }
    }
}
