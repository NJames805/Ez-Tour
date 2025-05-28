//
//  Home.swift
//  Ez Tour
//
//  Created by Nathanael James on 5/14/25.
//

import SwiftUI

//Blue Background
//Logo
//Start your tour
//Form
struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var mapviewModel: MapViewModel
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    @State private var navigateToLocations = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.blue.ignoresSafeArea(.all)
                VStack(spacing: 20) {
                    // Favorites Button
                    HStack {
                        Spacer()
                        NavigationLink {
                            FavoritesView(viewModel: favoritesViewModel, mapViewModel: mapviewModel, homeViewModel: viewModel)
                        } label: {
                            HStack {
                                Text("Favorites")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                Image(systemName: "heart.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.trailing)
                    
                    Spacer()
                    
                    // App Title
                    Text("Ez Tour")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                    
                    // Continue Button
                    Button(action: {
                        print("Calling Form")
                        viewModel.showSearchForm = true
                        // Load saved preferences
                        let preferences = viewModel.loadPreferences()
                        mapviewModel.pricelevel = preferences.priceLevel
                        mapviewModel.selectedType = preferences.placeType
                        print(preferences.priceLevel)
                        print(preferences.placeType)
                        print(mapviewModel.pricelevel ?? 56)
                        print(mapviewModel.selectedType)
                        if preferences.priceLevel > 0 {
                            viewModel.budgetSelected = true
                            viewModel.selectedBudget = String(repeating: "$", count: preferences.priceLevel)
                            mapviewModel.priceSelected = true
                        }
                        if !preferences.placeType.isEmpty {
                            viewModel.placeSelected = true
                            mapviewModel.typeSelected = true
                        }
                    }) {
                        Text("Start Your Tour")
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(maxWidth: 300)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(50)
                    }
                    .padding(.horizontal)
                    
                    //Search Form
                    if viewModel.showSearchForm {
                        SearchForm(mapviewModel: mapviewModel, viewModel: viewModel, navigateToLocations: $navigateToLocations)
                    }
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationDestination(isPresented: $navigateToLocations) {
                LocationsView(viewModel: mapviewModel, favoritesViewModel: favoritesViewModel, homeViewModel: viewModel)
            }
        }
    }
}


