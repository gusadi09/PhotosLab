//
//  PhotosLabApp.swift
//  PhotosLab
//
//  Created by Gus Adi on 05/10/23.
//

import SwiftUI

@main
struct PhotosLabApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject var networkMonitor = NetworkMonitor()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(networkMonitor)
        }
    }
}
