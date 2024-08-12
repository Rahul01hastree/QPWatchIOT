//
//  NetworkMonitorTest.swift
//  QP HT Applicationn
//
//  Created by Rahul Gangwar on 12.08.2024.
//

import WatchKit
import Network

class NetworkMonitor1 {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")

    init() {
        // Set up the path update handler which gets called automatically on network changes
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                // Network is available
                print("Connected to the Internet")
                // Trigger your desired actions here, like calling a delegate method or posting a notification
            } else {
                // No network connection
                print("No Internet connection")
                // Trigger your desired actions here
            }

            if path.isExpensive {
                print("Connection is on a metered network (e.g., cellular)")
            }
        }

        // Start the monitor on a background queue
        monitor.start(queue: queue)
    }
    
    deinit {
        // Stop monitoring when the instance is deallocated
        monitor.cancel()
    }
}

class InterfaceController: WKInterfaceController {
    private var networkMonitor: NetworkMonitor1?

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Initialize the network monitor; it will automatically receive callbacks on network status changes
        networkMonitor = NetworkMonitor1()
    }
}
