//
//  SignUp.swift
//  Ez Tour
//
//  Created by Nathanael James on 4/20/25.
//
import SwiftUI

struct DetailsView: View {
    @StateObject var viewModel: MapViewModel
    @StateObject var favoritesViewModel: FavoritesViewModel
    @StateObject var homeViewModel: HomeViewModel
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                PlaceNameView(name: viewModel.selectedPlace?.name)
                PhotoView(place: viewModel.selectedPlace)
                InfoSectionView(viewModel: viewModel, favoritesViewModel: favoritesViewModel)
            }
        }
        .onAppear {
            print("Selected Place: \(viewModel.selectedPlace?.name ?? "turtle")")
        }
        .background(Color.gray.opacity(0.1))
    }
}

// MARK: - Place Name View
private struct PlaceNameView: View {
    let name: String?
    
    var body: some View {
        Text(name ?? "No place selected")
            .font(.title)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
}

// MARK: - Photo View
private struct PhotoView: View {
    let place: Place?
    
    var body: some View {
        if let photos = place?.photos,
           let firstPhoto = photos.first {
            AsyncImage(url: URL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&photo_reference=\(firstPhoto.photo_reference)&key=AIzaSyDRJbltlpTpzIrfUDFHiKwaaqZTnqe13W8")) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(height: 250)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                        .clipped()
                        .cornerRadius(15)
                case .failure:
                    Image(systemName: "photo")
                        .font(.system(size: 50))
                        .frame(height: 250)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(15)
                @unknown default:
                    EmptyView()
                }
            }
        }
    }
}

// MARK: - Info Section View
private struct InfoSectionView: View {
    @ObservedObject var viewModel: MapViewModel
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            StatusRatingView(place: viewModel.selectedPlace)
            ActionButtonsView(viewModel: viewModel, favoritesViewModel: favoritesViewModel)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}

// MARK: - Status Rating View
private struct StatusRatingView: View {
    let place: Place?
    
    var body: some View {
        HStack(spacing: 20) {
            // Open Status
            VStack {
                Image(systemName: place?.opening_hours?.open_now == true ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(place?.opening_hours?.open_now == true ? .green : .red)
                Text(place?.opening_hours?.open_now == true ? "Open" : "Closed")
                    .font(.subheadline)
            }
            
            Divider()
            
            // Rating
            VStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text(String(format: "%.1f", place?.rating ?? 0.0))
                    .font(.subheadline)
            }
            
            Divider()
            
            // Price Level
            VStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.blue)
                Text(String(repeating: "$", count: place?.price_level ?? 0))
                    .font(.subheadline)
            }
        }
        .padding(.vertical)
    }
}

// MARK: - Action Buttons View
private struct ActionButtonsView: View {
    @ObservedObject var viewModel: MapViewModel
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    
    private var isFavorited: Bool {
        if let place = viewModel.selectedPlace {
            return favoritesViewModel.isFavorited(place)
        }
        return false
    }
    
    var body: some View {
        VStack(spacing: 15) {
            // Navigate Button
            Button(action: {
                if let place = viewModel.selectedPlace {
                    viewModel.openInMaps(
                        destinationLat: place.coordinate.latitude,
                        destinationLng: place.coordinate.longitude
                    )
                }
            }) {
                HStack {
                    Image(systemName: "map.fill")
                    Text("Navigate Here")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            // Favorite Button
            Button(action: {
                if let place = viewModel.selectedPlace {
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
                }
            }) {
                HStack {
                    Image(systemName: isFavorited ? "heart.fill" : "heart")
                    Text(isFavorited ? "Remove from Favorites" : "Add to Favorites")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFavorited ? Color.red.opacity(0.2) : Color.red.opacity(0.1))
                .foregroundColor(.red)
                .cornerRadius(10)
            }
        }
    }
}



