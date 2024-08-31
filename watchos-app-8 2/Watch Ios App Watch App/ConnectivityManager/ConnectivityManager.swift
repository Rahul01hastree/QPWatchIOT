//
//  ConnectivityManager.swift
//  QP HT Applicationn
//
//  Created by Rahul Gangwar on 30.08.2024.
//

import WatchKit
import Network

class ConnectivityManager: NSObject {
    
    static let shared = ConnectivityManager()
    private let monitor = NWPathMonitor()

    var isConnected: Bool {
        return monitor.currentPath.status == .satisfied
    }

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.updateConnectivityStatus(path: path)
        }
        monitor.start(queue: .main)
    }

    private func updateConnectivityStatus(path: NWPath) {
        if path.status == .satisfied {
            sendLocalDataToLocal()
        } else {
            print("Internet is disconnected")
        }
    }
    
    private func sendLocalDataToLocal(){
        print("current internet state :- \(isConnected)")
        if isConnected{
            LocaldataProcessor.shared.processAndSendData()
        }
    }
    
}
