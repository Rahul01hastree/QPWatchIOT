//
//  Watch_Ios_AppApp.swift
//  Watch Ios App Watch App
//
//  Created by HT-Mac-08 on 12/12/23.
//

import SwiftUI
import FirebaseDatabase
import FirebaseCore
//import WatchConnectivity

@main
struct Watch_Ios_App_Watch_AppApp: App {
    //let session = WCSession.default
    
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
       // session.activate()
      //  InternetChecker.shared.session.activate()
        PersistentContainer.shared.saveContext()
        
    }
    
    @ObservedObject var locationManager = LocationManager()
    
    @State private var showingAlert = false
    
    var body: some Scene {
        WindowGroup {
            
            ContentView()
                
        }
    }
}

