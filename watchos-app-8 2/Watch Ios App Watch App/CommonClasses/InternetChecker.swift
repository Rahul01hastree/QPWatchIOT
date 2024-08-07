//
//  InternetChecker.swift
//  QP HT Applicationn
//
//  Created by Rahul Gangwar on 7.08.2024.
//
import Network
import NetworkExtension
import networkext

final class InternetChecker {
    static let shared = InternetChecker()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    private var isConnected: Bool = false
    private var lastChecked: Date?
    private let checkInterval: TimeInterval = 10 // seconds for more frequent checks

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = (path.status == .satisfied)
            print("Network status updated: \(self?.isConnected == true ? "Connected" : "Not Connected")")
        }
        monitor.start(queue: queue)
    }
    
    
    func isConnectedToInternet(completion: @escaping (Bool) -> Void) {
        let now = Date()
        if let lastChecked = lastChecked, now.timeIntervalSince(lastChecked) < checkInterval {
            completion(isConnected)
        } else {
            lastChecked = now
            // Perform a direct check
            DispatchQueue.main.async {
                completion(self.isConnected)
            }
        }
    }
    
    func networkCall(completion: @escaping (Bool) -> Void) {
            let url = URL(string: "https://www.apple.com")!
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD"
            
            let task = URLSession.shared.dataTask(with: request) { _, response, error in
                if let httpResponse = response as? HTTPURLResponse {
                    completion(httpResponse.statusCode == 200)
                } else {
                    completion(false)
                }
            }
            task.resume()
        }
    
}
