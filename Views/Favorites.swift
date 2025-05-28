//
//  Favorites.swift
//  Ez Tour
//
//  Created by Nathanael James on 5/6/25.
//

import Foundation
import SwiftUI
import CoreLocation
import SwiftData

struct FavoritesView: View {
    @StateObject var viewModel: FavoritesViewModel
    @StateObject var mapViewModel: MapViewModel
    @StateObject var homeViewModel: HomeViewModel
    @Query private var favoritePlaces: [FavoritePlace]
    @State private var selectedPlace: Place?
    
    var body: some View {
        ZStack {
            Color.red.ignoresSafeArea(.all)
            VStack {
                Text("\(viewModel.favorites.count) Favorites")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: 200, maxHeight: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(radius: 2)
                    )
                    .padding(.top, 50)
                
                if viewModel.favorites.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                        Text("No favorites yet")
                            .font(.title2)
                            .foregroundColor(.white)
                        Text("Add places to your favorites to see them here")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 50)
                } else {
                    List {
                        ForEach(favoritePlaces) { place in
                            PlaceListItem(place: place.toPlace(), viewModel: mapViewModel, favoritesViewModel: viewModel, homeViewModel: homeViewModel)
                                .listRowBackground(Color.white)
                                .listRowSeparator(.hidden)
                                .padding(.vertical, 4)
                                .onTapGesture {
                                    let convertedPlace = place.toPlace()
                                    mapViewModel.selectedPlace = convertedPlace
                                    selectedPlace = convertedPlace
                                }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .navigationDestination(item: $selectedPlace) { place in
            DetailsView(viewModel: mapViewModel, favoritesViewModel: viewModel, homeViewModel: homeViewModel)
                .onAppear {
                    mapViewModel.selectedPlace = place
                }
        }
    }
}



