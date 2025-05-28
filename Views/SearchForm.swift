import SwiftUI

struct SearchForm: View {
    @StateObject var mapviewModel: MapViewModel
    @StateObject var viewModel: HomeViewModel
    @AppStorage("savedPriceLevel") private var savedPriceLevel: Int = 0
    @AppStorage("savedPlaceType") private var savedPlaceType: String = ""
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Binding var navigateToLocations: Bool
    
    private var title: String {
        if viewModel.placeSelected {
            let type = mapviewModel.selectedType
            return type.prefix(1).uppercased() + type.dropFirst()
        }
        return "Where To?"
    }
    
    private var placeTypeGrid: some View {
        let images = ["fork.knife", "mug.fill", "carrot", "building", "cup.and.saucer.fill", 
                     "house.fill", "storefront.fill", "tree.fill", "building.columns"]
        
        return LazyVGrid(columns: [
            GridItem(.adaptive(minimum: 100), spacing: 10)
        ], spacing: 10) {
            ForEach(0..<mapviewModel.placeTypes.count, id: \.self) { place in
                placeTypeButton(place: place, image: images[place])
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private func placeTypeButton(place: Int, image: String) -> some View {
        let type = mapviewModel.placeTypes[place]
        let capitalized = type.prefix(1).uppercased() + type.dropFirst()
        
        return VStack {
            Text(capitalized)
                .font(.system(size: 10))
            Button("", systemImage: image) {
                viewModel.placeSelected = true
                mapviewModel.selectedType = type
                mapviewModel.typeSelected = true
                savedPlaceType = type
            }
        }
    }
    
    private var priceMenu: some View {
        Menu(viewModel.selectedBudget) {
            ForEach(0...4, id: \.self) { index in
                Button(action: {
                    viewModel.budgetSelected = true
                    viewModel.selectedBudget = index == 0 ? "Free" : String(repeating: "$", count: index)
                    mapviewModel.pricelevel = index
                    mapviewModel.priceSelected = true
                    savedPriceLevel = index
                }) {
                    Text(index == 0 ? "Free" : String(repeating: "$", count: index))
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            // Bottom sheet
            VStack {
                HStack {
                    Spacer()
                    Button {
                        viewModel.showSearchForm = false
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .padding()
                            .foregroundColor(.black)
                    }
                }
                
                VStack(spacing: 20) {
                    //Price Options
                    HStack {
                        Text("Budget: ")
                            .font(.headline)
                        priceMenu
                    }
                    
                    // Place Type Selection
                    VStack(alignment: .center, spacing: 20) {
                        Text(title)
                            .font(.headline)
                        placeTypeGrid
                    }
                    
                    // Apply Button
                    Button {
                        // Save preferences
                        if let priceLevel = mapviewModel.pricelevel {
                            viewModel.savePreferences(priceLevel: priceLevel, placeType: mapviewModel.selectedType)
                        }
                        Task {
                            // Reset radius to initial value
                            mapviewModel.radius = 1500
                            // Clear existing places
                            mapviewModel.fetcher.places = []
                            // Reset any existing state
                            mapviewModel.priceSelected = true
                            mapviewModel.typeSelected = true
                            // Fetch new places
                            await mapviewModel.fetchPlacesIfValid()
                            print("Fetching places if valid")
                            navigateToLocations = true
                            viewModel.showSearchForm = false
                            dismiss()
                        }
                    } label: {
                        Text("Apply")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .opacity((viewModel.budgetSelected && viewModel.placeSelected && mapviewModel.userLocation != nil) ? 1.0 : 0.5)
                    .disabled(!(viewModel.budgetSelected && viewModel.placeSelected && mapviewModel.userLocation != nil))
                }
                .padding()
            }
            .background(Color.white)
            .cornerRadius(20)
            .padding(.horizontal)
            .padding(.bottom, 30)
            .transition(.move(edge: .bottom))
        }
    }
} 
