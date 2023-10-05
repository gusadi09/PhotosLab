//
//  ContentView.swift
//  PhotosLab
//
//  Created by Gus Adi on 05/10/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    @State var isShowImagePicker = false
    @State var image: UIImage? = nil

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Photo.photoId, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Photo>

    var body: some View {
        NavigationView {
            if networkMonitor.isConnected {
                List {
                    ForEach(items) { item in
                        NavigationLink {
                            retrieveImage(with: item.photoId ?? "")
                        } label: {
                            Text(item.photoId ?? "")
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .toolbar {
#if os(iOS)
                    ToolbarItem(placement: .topBarTrailing) {
                        EditButton()
                    }
#endif
                    ToolbarItem {
                        Button(action: {
                            isShowImagePicker.toggle()
                            
                        }) {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                }
                .sheet(isPresented: $isShowImagePicker, content: {
                    ImagePicker(takenPicture: $image)
                })
                .onChange(of: image) { oldValue, newValue in
                    if networkMonitor.isConnected {
                        // Add to firebase function
                    } else {
                        saveToDocumentDirectory(image: image, imageId: "\(items.count+1)")
                        addItem(id: "\(items.count+1)")
                    }
                }
                .onChange(of: networkMonitor.isConnected) { oldValue, newValue in
                    if newValue {
                        // Add to firebase function
                    } else {
                        saveToDocumentDirectory(image: image, imageId: "\(items.count+1)")
                        addItem(id: "\(items.count+1)")
                    }
                }
            } else {
                
                Text("Offline")
            }
        }
    }

    private func addItem(id: String) {
        withAnimation {
            let newItem = Photo(context: viewContext)
            newItem.photoId = id

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func getDocumentsDirectory() throws -> URL {
         return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
    func saveToDocumentDirectory(image: UIImage?, imageId: String) {
        if let image = image, let data = image.jpegData(compressionQuality: 0.7) {
            do {
                let filename = try getDocumentsDirectory().appendingPathComponent(imageId)
                try data.write(to: filename, options: [[.atomicWrite, .completeFileProtection]])
            } catch {
                print("error saving data")
            }
        }
    }
    
    func retrieveImage(with id: String) -> Image {
        let dummyImage = Image(systemName: "person")
        do {
            let filename =  try getDocumentsDirectory().appendingPathComponent(id)
            let data = try Data(contentsOf: filename)
            if let uiImage = UIImage(data: data) {
                return Image(uiImage: uiImage)
            }
        } catch {
            print("error loading data")
            return dummyImage
        }
        
        return dummyImage
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(NetworkMonitor())
}
