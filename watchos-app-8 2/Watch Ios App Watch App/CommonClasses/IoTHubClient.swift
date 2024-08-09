//
//  IoTHubClient.swift
//  QP HT Applicationn
//
//  Created by Rahul Gangwar on 29.07.2024.
//

import Foundation


class IoTHubClient {
    
    static let shared = IoTHubClient()
    private var iotHubName = ""
    private var iotDeviceID = ""
    private var iotSASToken = ""
    private var urlSession: URLSession
    
    
    init() {
        
        let configuration = URLSessionConfiguration.default
        self.urlSession = URLSession(configuration: configuration)
    }
    

    func sendClientDataToIOT(userInfo: DeviceTelemetry, completion: @escaping (Result<Void, Error>) -> Void) {
        
        self.updateValueFromUserDefaults()
       // let testingString = "https://Watch.azure-devices.net/devices/\(iotDeviceID)/messages/events?api-version=2020-09-30"
        let urlString = "\(iotHubName)/devices/\(iotDeviceID)/messages/events?api-version=2021-04-12"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(iotSASToken, forHTTPHeaderField: "Authorization")
        
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
    
    
    private func getRequiredValuesUserDefault(){
        if let SASToken = UserDefaults.standard.string(forKey: "currentSelectedSAS"){
            self.iotSASToken = SASToken
        }
        if let deviceID = UserDefaults.standard.string(forKey: "currentSelectedDeviceID"){
            self.iotDeviceID = deviceID
        }
    }
    
    private func updateValueFromUserDefaults(){

        if let SASToken = UserDefaults.standard.string(forKey: "currentSelectedSAS"){
            self.iotSASToken = SASToken
        }else{
            self.iotSASToken = IoTHubClient.watch5SASToken
        }
        
        if let deviceID = UserDefaults.standard.string(forKey: "currentSelectedDeviceID"){
            self.iotDeviceID = deviceID
        }else{
            self.iotDeviceID = IoTHubClient.watch5DeviceID
        }
        
        if let hubName = UserDefaults.standard.string(forKey: "currentSelectedHUBName"){
            self.iotHubName = hubName
        }else{
            self.iotHubName = IoTHubClient.huBName
        }

    }
    
}

extension IoTHubClient {
    
    static let watch5SASToken = "SharedAccessSignature sr=AppleWatch.azure-devices.us%2Fdevices%2Fwatch5&sig=KuazUmp4j2Gvf60SY773VA9mkfcXo3CqajnHI7I8ap0%3D&se=1754680760"
    static let watch5DeviceID = "watch5"
    static let huBName = "https://AppleWatch.azure-devices.us"
    
}
