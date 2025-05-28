//
//  Ez_TourApp.swift
//  Ez Tour
//
//  Created by Nathanael James on 4/18/25.
//

import Clerk
import SwiftUI
import SwiftData

@main
struct Ez_TourApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: FavoritePlace.self)
    }
}
