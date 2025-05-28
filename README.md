# Ez Tour

Ez Tour is an iOS application that helps users discover and explore places around them. The app provides a seamless experience for finding restaurants, cafes, attractions, and other points of interest based on user preferences and location.

## Features

- Location-based place discovery
- Customizable search filters (budget, place type)
- Interactive map view
- Place details and information
- Favorites system
- Distance measurement options
- Dynamic place loading

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+
- Core Location framework
- MapKit framework
- Google Places API key

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/ez-tour.git
```

2. Set up your Google API key:
   - Copy `Config.xcconfig.template` to `Config.xcconfig`
   - Replace `your_api_key_here` in `Config.xcconfig` with your actual Google Places API key
   - Make sure `Config.xcconfig` is added to your Xcode project

3. Open the project in Xcode:
```bash
cd ez-tour
open Ez\ Tour.xcodeproj
```

4. Build and run the project in Xcode

## Usage

1. Launch the app
2. Allow location access when prompted
3. Use the search form to set your preferences:
   - Select a budget level
   - Choose a place type
4. View the list of places or switch to map view
5. Tap on any place to view more details
6. Add places to favorites for quick access

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture pattern and uses SwiftUI for the user interface. Key components include:

- Views: SwiftUI views for the user interface
- ViewModels: Business logic and data management
- Models: Data structures and Core Data models
- Services: Location and data fetching services

## License

This project is licensed under the MIT License - see the LICENSE file for details. 