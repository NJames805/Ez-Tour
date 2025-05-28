//
//  Locations.swift
//  Ez Tour
//
//  Created by Nathanael James on 5/15/25.
//
import SwiftUI
import CoreLocation
import SwiftData

struct LocationsView : View {
    @StateObject var viewModel : MapViewModel
    @StateObject var favoritesViewModel: FavoritesViewModel
    @StateObject var homeViewModel : HomeViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var selectedPlace: Place?
    @State private var navigateToLocations = false
    @State private var showSearchForm = false
    @State private var refreshID = UUID()
    
    var body: some View {
        ZStack {
            Color.blue
            VStack {
                Text("Found \(viewModel.fetcher.places.count) places")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: 200, maxHeight: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(radius: 2)
                    )
                    .padding(.top, 50)
                    
                Button("Switch distance measurement") {
                    viewModel.switchDistanceMeasurement()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                
                List {
                    ForEach(Array(viewModel.sortedPlaces().enumerated()), id: \.element.id) { index, place in
                        PlaceListItem(place: place, viewModel: viewModel, favoritesViewModel: favoritesViewModel, homeViewModel: homeViewModel)
                            .listRowBackground(Color.white)
                            .listRowSeparator(.hidden)
                            .padding(.vertical, 4)
                            .onTapGesture {
                                viewModel.selectedPlace = place
                                selectedPlace = place
                            }
                            .onAppear {
                                if index == viewModel.sortedPlaces().count - 1 {
                                    print("Reached the bottom of the list!")
                                }
                            }
                    }
                    
                    // Load More Button
                    Button(action: {
                        Task {
                            if viewModel.radius < 15000 {
                                viewModel.isLoadingMore = true
                                viewModel.radius += 5000
                                print(viewModel.radius)
                                await viewModel.fetchPlacesIfValid()
                                viewModel.isLoadingMore = false
                            }
                        }
                    }) {
                        HStack {
                            if viewModel.isLoadingMore {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                    .padding(.trailing, 5)
                            } else {
                                Image(systemName: "arrow.down.circle.fill")
                            }
                            Text(viewModel.radius >= 15000 ? "No more places" : "Load More Places")
                        }   
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 2)
                    }
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 8)
                    .opacity(viewModel.radius >= 15000 ? 0.5 : 1)
                    .disabled(viewModel.radius >= 15000 || viewModel.isLoadingMore)
                    
                    if viewModel.radius >= 15000 {
                        Text("Want to see more places? Adjust your search!")
                            .font(.headline)
                            .padding()
                        Button("Adjust Search") {
                            showSearchForm = true
                            // Load saved preferences
                            let preferences = homeViewModel.loadPreferences()
                            viewModel.pricelevel = preferences.priceLevel
                            viewModel.selectedType = preferences.placeType
                            if preferences.priceLevel > 0 {
                                homeViewModel.budgetSelected = true
                                homeViewModel.selectedBudget = String(repeating: "$", count: preferences.priceLevel)
                                viewModel.priceSelected = true
                            }
                            if !preferences.placeType.isEmpty {
                                homeViewModel.placeSelected = true
                                viewModel.typeSelected = true
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .listRowBackground(Color.clear)
                        .padding(.vertical, 8)
                    }
                }
                .scrollContentBackground(.hidden)
                .id(refreshID)
            }
        }
        .navigationDestination(item: $selectedPlace) { place in
            DetailsView(viewModel: viewModel, favoritesViewModel: favoritesViewModel, homeViewModel: homeViewModel)
                .onAppear {
                    viewModel.selectedPlace = place
                }
        }
        .sheet(isPresented: $showSearchForm) {
            SearchForm(mapviewModel: viewModel, viewModel: homeViewModel, navigateToLocations: $navigateToLocations)
                .onDisappear {
                    refreshID = UUID()
                }
        }
        .onAppear {
            favoritesViewModel.updateModelContext(modelContext)
        }
        .onChange(of: modelContext) { _, newContext in
            favoritesViewModel.updateModelContext(newContext)
        }
        .onChange(of: viewModel.fetcher.places) { _, _ in
            refreshID = UUID()
        }
    }
}

struct PlaceListItem: View {
    let place: Place
    @ObservedObject var viewModel: MapViewModel
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    @ObservedObject var homeViewModel: HomeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with name and status
            HStack {
                Text(place.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                StatusBadge(isOpen: place.opening_hours?.open_now ?? false)
            }
            
            // Rating and Price
            HStack(spacing: 16) {
                RatingView(rating: place.rating ?? 0.0)
                PriceLevelView(priceLevel: place.price_level ?? 0)
            }
            
            // Distance
            if let userLocation = viewModel.userLocation {
                let userLoc = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                let placeLoc = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
                let distance = userLoc.distance(from: placeLoc)
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.blue)
                    Text(viewModel.formatDistance(distance))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button {
                    viewModel.selectedPlace = place
                } label: {
                    HStack {
                        Image(systemName: "info.circle.fill")
                        Text("View Details")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                FavoriteButton(viewModel: viewModel, favoritesViewModel: favoritesViewModel, place: place)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(radius: 2)
        )
        .padding(.horizontal, 4)
    }
}

struct StatusBadge: View {
    let isOpen: Bool
    
    var body: some View {
        Text(isOpen ? "Open" : "Closed")
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(isOpen ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
            )
            .foregroundColor(isOpen ? .green : .red)
    }
}

struct RatingView: View {
    let rating: Double
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
            Text(String(format: "%.1f", rating))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct PriceLevelView: View {
    let priceLevel: Int
    
    var body: some View {
        Text(String(repeating: "$", count: priceLevel))
            .font(.subheadline)
            .foregroundColor(.secondary)
    }
}

struct FavoriteButton: View {
    @ObservedObject var viewModel: MapViewModel
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    let place: Place
    
    private var isFavorited: Bool {
        favoritesViewModel.isFavorited(place)
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                if isFavorited {
                    favoritesViewModel.removeFromFavorites(place)
                } else {
                    favoritesViewModel.addToFavorites(place)
                }
                viewModel.showHeart = true
                viewModel.isFavorited = !isFavorited
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation {
                    viewModel.showHeart = false
                }
            }
        }) {
            HStack {
                Image(systemName: isFavorited ? "heart.fill" : "heart")
                Text(isFavorited ? "Remove" : "Favorite")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isFavorited ? Color.red.opacity(0.2) : Color.red.opacity(0.1))
            .foregroundColor(.red)
            .cornerRadius(10)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}



