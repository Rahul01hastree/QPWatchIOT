//
//  Watch_Ios_AppApp.swift
//  Watch Ios App Watch App
//
//  Created by HT-Mac-08 on 12/12/23.
//

import SwiftUI
import FirebaseDatabase
import FirebaseCore

@main
struct Watch_Ios_App_Watch_AppApp: App {
        
    init() {
        FirebaseApp.configure()
        if let storedStorageAccountNames = UserDefaults.standard.array(forKey: storageAccountNamesArrayDefaultsKey) as? [String] {
            storageAccountNamesArr = storedStorageAccountNames
        }
        if let storedFileShareNames = UserDefaults.standard.array(forKey: fileShareNamesArrayDefaultsKey) as? [String] {
            fileShareNamesArr = storedFileShareNames
        }
        if let sasToken = UserDefaults.standard.string(forKey: sasTokenDefaultsKey) {
            print("SAS TOKEN : \(sasToken)")
            sasTokenNew = sasToken
        }
        
        PersistentContainer.shared.saveContext()
//        let persistentContainer: NSPersistentContainer = {
//                let container = NSPersistentContainer(name: "ModelName")
//                container.loadPersistentStores { storeDescription, error in
//                    if let error = error as NSError? {
//                        fatalError("Unresolved error \(error), \(error.userInfo)")
//                    }
//                }
//                return container
//            }()
        
        
    }
    
    @ObservedObject var locationManager = LocationManager()
    
    @State private var showingAlert = false
    
    var body: some Scene {
        WindowGroup {
            
            ContentView()
                
        }
    }
}

