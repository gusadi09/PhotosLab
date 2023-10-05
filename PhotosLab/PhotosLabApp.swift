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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
