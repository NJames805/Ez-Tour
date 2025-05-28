//
//  HomeViewModel.swift
//  Ez Tour
//
//  Created by Nathanael James on 5/14/25.
//
import Foundation
import SwiftUI



class HomeViewModel: ObservableObject {
    @Published var showSearchForm = false
    @Published var showPlaceSelection = false
    @Published var selectedBudget: String = "Take your pick!"
    @Published var budgetSelected: Bool = false
    @Published var placeSelected: Bool = false
    
    @AppStorage("savedPriceLevel") private var savedPriceLevel: Int = 0
    @AppStorage("savedPlaceType") private var savedPlaceType: String = ""
    
    func savePreferences(priceLevel: Int, placeType: String) {
        savedPriceLevel = priceLevel
        savedPlaceType = placeType
    }
    
    func loadPreferences() -> (priceLevel: Int, placeType: String) {
        return (savedPriceLevel, savedPlaceType)
    }
}
