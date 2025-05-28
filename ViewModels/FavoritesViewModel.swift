//
//  FavoritesViewModel.swift
//  Ez Tour
//
//  Created by Nathanael James on 5/14/25.
//
import Foundation
import SwiftUI
import SwiftData

class FavoritesViewModel: ObservableObject {
    private var modelContext: ModelContext
    @Published private var favoritePlaces: [FavoritePlace] = []
    
    var favorites: [Place] {
        favoritePlaces.map { $0.toPlace() }
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadFavorites()
    }
    
    func updateModelContext(_ newContext: ModelContext) {
        self.modelContext = newContext
        loadFavorites()
    }
    
    private func loadFavorites() {
        let descriptor = FetchDescriptor<FavoritePlace>()
        self.favoritePlaces = (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func isFavorited(_ place: Place) -> Bool {
        return favoritePlaces.contains { $0.id == place.id }
    }
    
    func addToFavorites(_ place: Place) {
        let favoritePlace = FavoritePlace(from: place)
        modelContext.insert(favoritePlace)
        try? modelContext.save()
        loadFavorites() // Reload after adding
    }
    
    func removeFromFavorites(_ place: Place) {
        let placeId = place.id
        let descriptor = FetchDescriptor<FavoritePlace>(
            predicate: #Predicate { favoritePlace in
                favoritePlace.id == placeId
            }
        )
        
        do {
            if let favoritePlace = try modelContext.fetch(descriptor).first {
                modelContext.delete(favoritePlace)
                try modelContext.save()
                loadFavorites() // Reload after removing
            }
        } catch {
            print("Error removing favorite: \(error)")
        }
    }
}
