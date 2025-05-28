import Foundation
import SwiftData

@Model
class FavoritePlace {
    @Attribute(.unique) var id: String
    @Attribute(.unique) var name: String
    var latitude: Double
    var longitude: Double
    var priceLevel: Int
    var rating: Double
    var isOpen: Bool
    var photoReference: String?
    var photoHeight: Int
    var photoWidth: Int
    
    init(from place: Place) {
        self.id = place.id
        self.name = place.name
        self.latitude = place.coordinate.latitude
        self.longitude = place.coordinate.longitude
        self.priceLevel = place.price_level ?? 0
        self.rating = place.rating ?? 0.0
        self.isOpen = place.opening_hours?.open_now ?? false
        
        if let photo = place.photos?.first {
            self.photoReference = photo.photo_reference
            self.photoHeight = photo.height
            self.photoWidth = photo.width
        } else {
            self.photoReference = nil
            self.photoHeight = 0
            self.photoWidth = 0
        }
    }
    
    func toPlace() -> Place {
        Place(
            id: id,
            name: name,
            geometry: Place.Geometry(
                location: Place.Geometry.Location(
                    lat: latitude,
                    lng: longitude
                )
            ),
            price_level: priceLevel,
            rating: rating,
            opening_hours: Place.OpeningHours(open_now: isOpen),
            photos: photoReference.map { ref in
                [Place.Photo(
                    photo_reference: ref,
                    height: photoHeight,
                    width: photoWidth
                )]
            }
        )
    }
} 
