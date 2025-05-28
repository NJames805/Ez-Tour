//
//  Map.swift
//  Ez Tour
//
//  Created by Nathanael James on 4/20/25.
//
import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var viewModel: MapViewModel
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(spacing: 0) {
            searchHeader
            mapSection
            Spacer()
        }
        .task {
            for await newLocation in viewModel.locationManager.$userLocation.values {
                viewModel.userLocation = newLocation
            }
        }
    }

    private var searchHeader: some View {
        HStack {
            Menu {
                ForEach(0..<5) { level in
                    Button("\(viewModel.priceLabel(for: level))") {
                        viewModel.pricelevel = level
                        viewModel.priceSelected = true
                    }
                }
            } label: {
                Text(viewModel.pricelevel != nil ? "Price Level: \(viewModel.pricelevel!)" : "Choose your price level")
            }

            Menu {
                ForEach(viewModel.placeTypes, id: \.self) { place in
                    Button(place) {
                        viewModel.selectedType = place
                        viewModel.typeSelected = true
                    }
                }
            } label: {
                Text(!viewModel.selectedType.isEmpty ? "PlaceType: \(viewModel.selectedType)" : "Choose your place type")
            }

            Button("Search") {
                Task {
                    await viewModel.fetchPlacesIfValid()
                }
            }
            .disabled(!(viewModel.priceSelected && viewModel.typeSelected))
        }
        .padding()
    }

    private var mapSection: some View {
        ZStack(alignment: .topTrailing) {
            Map(position: $viewModel.position, selection: $viewModel.selectedMarker) {
                ForEach(viewModel.fetcher.places, id: \.id) { place in
                    Marker(place.name, coordinate: place.coordinate).tag(place.id)
                }
            }
            .ignoresSafeArea()
            .mapControls { MapUserLocationButton() }
            .onChange(of: viewModel.position) {
                if !viewModel.isSelectingMarker {
                    viewModel.selectedMarker = nil
                    viewModel.selectedPlace = nil
                } else {
                    viewModel.isSelectingMarker = false
                }
            }
            .onChange(of: viewModel.selectedMarker) { _, newValue in
                if let markerID = newValue {
                    viewModel.handleMarkerSelection(markerID: markerID)
                }
            }
            if let place = viewModel.selectedPlace {
                placeDetail(place)
            }
        }
    }

    private func placeDetail(_ place: Place) -> some View {
        VStack {
            Text(place.name)
                .font(.headline)
            Text("Rating: \(String(format: "%.1f", place.rating ?? 0.0))")
            Text("Price Level: \(String(repeating: "$", count: place.price_level ?? 0))")
            Text(place.opening_hours?.open_now == true ? "Open" : "Closed")
            
            ZStack {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        if favoritesViewModel.isFavorited(place) {
                            favoritesViewModel.removeFromFavorites(place)
                        } else {
                            favoritesViewModel.addToFavorites(place)
                        }
                        viewModel.showHeart = true
                        viewModel.isFavorited = !favoritesViewModel.isFavorited(place)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        withAnimation {
                            viewModel.showHeart = false
                        }
                    }
                } label: {
                    Label(
                        favoritesViewModel.isFavorited(place) ? "Remove from Favorites" : "Add to Favorites",
                        systemImage: favoritesViewModel.isFavorited(place) ? "heart.fill" : "heart"
                    )
                    .foregroundColor(favoritesViewModel.isFavorited(place) ? .red : .blue)
                }
                .buttonStyle(BorderlessButtonStyle())

                if viewModel.showHeart {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.red)
                        .scaleEffect(viewModel.showHeart ? 1.0 : 0.5)
                        .opacity(viewModel.showHeart ? 1 : 0)
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(1)
                }
            }
            .padding(.vertical, 50)

            Button("Navigate Here") {
                viewModel.openInMaps(destinationLat: place.coordinate.latitude, destinationLng: place.coordinate.longitude)
            }
        }
        .padding()
    }
}
