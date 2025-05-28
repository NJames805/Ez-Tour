//
//  ContentView.swift
//  Ez Tour
//
//  Created by Nathanael James on 4/18/25.
//

import SwiftUI
import MapKit
import SwiftData

enum Tabs: Equatable, Hashable, Identifiable {
    case locations
    case home
    case map
    case favorites
    case details
    var id: Self { self }
}

struct Place: Identifiable, Decodable, Equatable, Hashable {
    var id: String
    var name: String
    var geometry: Geometry
    var price_level: Int?
    var rating: Double?
    var opening_hours: OpeningHours?
    var photos: [Photo]?
    
    var distance: CLLocationDistance? // Distance in meters
    
    enum CodingKeys: String, CodingKey {
        case id = "place_id"
        case name
        case geometry
        case price_level
        case opening_hours
        case rating
        case photos
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: geometry.location.lat,
            longitude: geometry.location.lng
        )
    }
    
    struct Geometry: Decodable, Hashable {
        let location: Location
        
        struct Location: Decodable, Hashable {
            let lat: Double
            let lng: Double
        }
    }
    
    struct OpeningHours: Decodable, Hashable {
        let open_now: Bool?
    }
    
    struct Photo: Decodable, Hashable {
        let photo_reference: String
        let height: Int
        let width: Int
    }
    
    static func == (lhs: Place, rhs: Place) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    mutating func updateDistance(from userLocation: CLLocation) {
        let placeLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.distance = userLocation.distance(from: placeLocation)
    }
}

struct ContentView: View {
    @StateObject private var mapviewModel = MapViewModel()
    @StateObject private var homeviewModel = HomeViewModel()
    @StateObject private var favoritesViewModel: FavoritesViewModel
    @Environment(\.modelContext) private var modelContext
    
    init() {
        // Initialize favoritesViewModel with a temporary context
        // It will be updated when the view appears
        _favoritesViewModel = StateObject(wrappedValue: FavoritesViewModel(modelContext: ModelContext(try! ModelContainer(for: FavoritePlace.self))))
    }
    
    var body: some View {
        NavigationStack {
            HomeView(
                viewModel: homeviewModel,
                mapviewModel: mapviewModel,
                favoritesViewModel: favoritesViewModel
            )
        }
        .onAppear {
            // Update the favoritesViewModel with the correct context
            favoritesViewModel.updateModelContext(modelContext)
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tabs

    var body: some View {
        HStack{
            Spacer()
            TabIcon(systemName: "house", tab: .home, selectedTab: $selectedTab)
            Spacer()
            TabIcon(systemName: "heart", tab: .favorites, selectedTab: $selectedTab)
            // Person icon triggers confirmation
            Spacer()
        }
        .frame(height:55)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .frame(maxWidth: .infinity) // Fill horizontal space
        .ignoresSafeArea(edges: .bottom) // Extend to bottom
    }
}

struct TabIcon: View {
    let systemName: String
    let tab: Tabs
    @Binding var selectedTab: Tabs

    var body: some View {
        Button {
            selectedTab = tab
        } label: {
            Image(systemName: systemName)
                .font(.system(size: 24))
                .foregroundColor(selectedTab == tab ? .blue : .gray)
        }
    }
}



