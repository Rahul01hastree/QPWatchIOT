//
//  ConnectivityManager.swift
//  QP HT Applicationn
//
//  Created by Rahul Gangwar on 30.08.2024.
//

import Foundation
import Network

class ConnectivityManager {
    
    static let shared = ConnectivityManager()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)

    var isConnected: Bool = false
    var connectionType: ConnectionType = .unknown

    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }

    private init() {
        startMonitoring()
    }

    func startMonitoring() {
        monitor.start(queue: queue)

        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
            self?.getConnectionType(path)
            self?.checkInternetConnection(){ isConnected in
                self?.isConnected = isConnected
            }
        }
    }

    func stopMonitoring() {
        monitor.cancel()
    }

    private func getConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
    }
    
    func checkInternetConnection(completion: @escaping (Bool) -> Void) {
           guard let url = URL(string: "https://www.google.com") else {
               completion(false)
               return
           }

           var request = URLRequest(url: url)
           request.httpMethod = "HEAD"  // Use HEAD request to avoid downloading unnecessary data

           let task = URLSession.shared.dataTask(with: request) { (_, response, error) in
               if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                   completion(true)
                   LocaldataProcessor.shared.processAndSendData()
               } else {
                   completion(false)
               }
           }

           task.resume()
       }
    
}
