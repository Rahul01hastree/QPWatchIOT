//
//  IoTHubClient.swift
//  QP HT Applicationn
//
//  Created by Rahul Gangwar on 29.07.2024.
//

import Foundation


class IoTHubClient {
    
    static let shared = IoTHubClient()
    private let iotHubName = "AppleWatch"
    private let deviceId = "watch5"
    private let sasToken = "SharedAccessSignature sr=Watch.azure-devices.net%2Fdevices%2Fwatch5&sig=bw26zCHccqZaQvJA35F8gGe%2F%2FQ4PYmeeFSoGDuD6hR0%3D&se=1722937675"
    private var urlSession: URLSession
    
    
    init() {
        let configuration = URLSessionConfiguration.default
        self.urlSession = URLSession(configuration: configuration)
    }
    

    func sendClientDataToIOT(userInfo: DeviceTelemetry, completion: @escaping (Result<Void, Error>) -> Void) {
        //https://AppleWatch.azure-devices.us/devices/watch5/messages/events?api-version=2021-04-12
    let testingString = "https://Watch.azure-devices.net/devices/watch5/messages/events?api-version=2020-09-30"
        let urlString = "https://\(iotHubName).azure-devices.us/devices/\(deviceId)/messages/events?api-version=2021-04-12"
        guard let url = URL(string: testingString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        //SharedAccessSignature
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(sasToken, forHTTPHeaderField: "Authorization")
        
        guard let body = try? JSONEncoder().encode(userInfo) else {
            completion(.failure(NSError(domain: "JSON Encoding Error", code: -1, userInfo: nil)))
            return
        }
        request.httpBody = body
        
        let task = urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
                let error = NSError(domain: "Unexpected Response", code: -1, userInfo: nil)
                completion(.failure(error))
                return
            }
            
            completion(.success(()))
        }
        
        task.resume()
    }
    
    
}
