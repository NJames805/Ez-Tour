//
//  PlaceFetcher.swift
//  Ez Tour
//
//  Created by Nathanael James on 5/14/25.
//
import Foundation
import SwiftUI
import CoreLocation

@MainActor
class PlaceFetcher: ObservableObject {
    @Published var places: [Place] = []
    @Published var placeImages: [String: UIImage] = [:]  // Cache for place images
    @Published var isLoading = false
    @Published var error: Error?
    
    private let apiKey: String
    
    init() {
        // Get API key from configuration
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_API_KEY") as? String {
            self.apiKey = apiKey
        } else {
            fatalError("Google API key not found in configuration")
        }
    }
    
    struct GooglePlacesResponse: Decodable {
        let results: [Place]
        let status: String
    }
    
    //Get Places (Not only restaurants)
    func fetchNearbyRestaurants(priceLevel: Int?, placeType: String,userLocation: CLLocationCoordinate2D? ,setRadius:Int) async {
        guard let priceLevel = priceLevel else { return }
        guard let userLocation = userLocation else {
            print("User location not available yet")
            return
        }
        
        print("Calling API")
        let lat = userLocation.latitude
        let lng = userLocation.longitude
        let radius = setRadius
        print("Radius is",radius)
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat),\(lng)&radius=\(radius)&type=\(placeType)&key=\(apiKey)") else { return }
        
        print("API successfully called at location: \(lat), \(lng)")
        
        do {
            print("Fetching data...")
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            print("Data is \(data)")
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Status Code: \(httpResponse.statusCode)")
                print("Headers: \(httpResponse.allHeaderFields)")
                
                guard httpResponse.statusCode == 200 else {
                    print("Bad status code: \(httpResponse.statusCode)")
                    return
                }
            }
            
            guard let rawResponse = String(data: data, encoding: .utf8) else {
                print("Could not decode response as UTF-8 string")
                return
            }
            
            print("Raw Response Body:\n\(rawResponse)")
            
            if rawResponse.contains("REQUEST_DENIED") || rawResponse.contains("OVER_QUERY_LIMIT") || rawResponse.contains("INVALID_REQUEST") {
                print("Google API error detected in response!")
                return
            }
            
            print("Trying to decode...")
            let decoded = try JSONDecoder().decode(GooglePlacesResponse.self, from: data)
            print("Successfully decoded")
            
            // Filter by price level and remove duplicates
            let newPlaces = decoded.results.filter { $0.price_level != nil && $0.price_level == priceLevel }
            let existingIds = Set(self.places.map { $0.id })
            let uniqueNewPlaces = newPlaces.filter { !existingIds.contains($0.id) }
            
            // Append only unique places
            self.places.append(contentsOf: uniqueNewPlaces)
            
            print("Fetched \(decoded.results.count) places")
            print("Filtered \(newPlaces.count) places by price")
            print("Added \(uniqueNewPlaces.count) unique places")
            
        }  catch let decodingError as DecodingError {
            switch decodingError {
            case .typeMismatch(let type, let context):
                print("Type mismatch: \(type), context: \(context)")
            case .valueNotFound(let type, let context):
                print("Value not found: \(type), context: \(context)")
            case .keyNotFound(let key, let context):
                print("Key '\(key)' not found, context: \(context)")
            case .dataCorrupted(let context):
                print("Data corrupted: \(context)")
            default:
                print("Decoding error: \(decodingError)")
            }
        } catch {
            print("Error fetching places: \(error)")
        }
    }
    
    //Marker Selection
    func markerSelected(markerID: String) {
           print("Marker selected with ID: \(markerID)")
           print("coord is \(String(describing: places.first?.coordinate))")
           print(places.first(where: { $0.id == markerID }) ?? "Nothing Found")
    }
    
    func fetchPlacePhoto(photoReference: String) async -> UIImage? {
        let maxWidth = 400
        let urlString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=\(maxWidth)&photo_reference=\(photoReference)&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                return image
            }
        } catch {
            print("Error fetching place photo: \(error)")
        }
        return nil
    }
    
    func fetchPlaces(latitude: Double, longitude: Double, radius: Int, placeType: String) async {
        isLoading = true
        error = nil
        
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=\(radius)&type=\(placeType)&key=\(apiKey)") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(PlacesResponse.self, from: data)
            DispatchQueue.main.async {
                self.places = response.results
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.error = error
                self.isLoading = false
            }
        }
    }
    
    func fetchPlaceDetails(placeId: String) async -> PlaceDetails? {
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeId)&fields=name,formatted_address,formatted_phone_number,website,opening_hours,rating,reviews,photos&key=\(apiKey)") else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(PlaceDetailsResponse.self, from: data)
            return response.result
        } catch {
            print("Error fetching place details: \(error)")
            return nil
        }
    }
    
    func getPhotoURL(photoReference: String, maxWidth: Int = 400) -> URL? {
        let urlString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=\(maxWidth)&photo_reference=\(photoReference)&key=\(apiKey)"
        return URL(string: urlString)
    }
}
