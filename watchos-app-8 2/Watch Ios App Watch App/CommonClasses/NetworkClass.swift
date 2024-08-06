//
//  NetworkClass.swift
//  Watch Ios App Watch App
//
//  Created by Apps we love on 19/12/23.
//

import Foundation
import Network

class NetworkMonitor {
    func checkNetworkType() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
//            print(path.status)
        DispatchQueue.main.async {
            if path.status == .satisfied {
                if path.usesInterfaceType(.wifi) {
                    print("Connected to Wi-Fi")
                    networkType = "WIFI"
                } else if path.usesInterfaceType(.cellular) {
                    print("Connected to Cellular (LTE/5G)")
                    networkType = "LTE"
                }
            } else {
                print("Not connected to any network")
                networkType = "NOT CONNECTED"
            }
        }
        }

        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
        
    }

}


class NetworkReachability {

    var pathMonitor: NWPathMonitor!
    var path: NWPath?
    lazy var pathUpdateHandler: ((NWPath) -> Void) = { path in
        self.path = path
        if path.status == NWPath.Status.satisfied {
            print("Connected123")
        } else if path.status == NWPath.Status.unsatisfied {
            print("unsatisfied123")
        } else if path.status == NWPath.Status.requiresConnection {
            print("requiresConnection123")
        }
    }

    let backgroudQueue = DispatchQueue.global(qos: .background)

    init() {
        pathMonitor = NWPathMonitor()
        pathMonitor.pathUpdateHandler = self.pathUpdateHandler
       

        pathMonitor.start(queue: backgroudQueue)
    }
    
    func isInternetAvailable() -> Bool {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "Monitor")

        var isAvailable: Bool = false
        let semaphore = DispatchSemaphore(value: 0)

        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                isAvailable = true
            } else if path.status == .unsatisfied {
                isAvailable = false
            } else if path.status == .requiresConnection {
                isAvailable = false
            }
            semaphore.signal()
        }

        monitor.start(queue: queue)
        
        // Wait for the pathUpdateHandler to be called.
        semaphore.wait()

        monitor.cancel()
        
        return isAvailable
    }
    
    func isInternetAvailable(completion: @escaping (Bool) -> Void) {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "Monitor")
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                // Check by making an actual network request
                var request = URLRequest(url: URL(string: "https://www.google.com")!)
                request.httpMethod = "HEAD"
                let task = URLSession.shared.dataTask(with: request) { _, response, error in
                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
                task.resume()
            } else {
                completion(false)
            }
            monitor.cancel() // Stop the monitor after the first check
        }
        
        monitor.start(queue: queue)
    }
    
    func performNetworkRequest(completion: @escaping (Bool) -> Void) {
        // Perform a simple HTTP request to verify internet access
        var request = URLRequest(url: URL(string: "https://www.google.com")!)
        request.httpMethod = "HEAD"
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
        task.resume()
    }



  class func isNetworkAvailable() -> Bool {
        if let path = NetworkReachability().path {
            if path.status == NWPath.Status.satisfied {
                return true
            }else{
                return false
            }
        }
        return false
    }
}
