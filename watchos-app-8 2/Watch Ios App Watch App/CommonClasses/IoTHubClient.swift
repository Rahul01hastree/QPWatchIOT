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
    
    private let extensionsIndex: Int
    private let extensions: String?
    
    
    init() {
        
        let configuration = URLSessionConfiguration.default
        self.urlSession = URLSession(configuration: configuration)
        
        self.extensionsIndex = UserDefaults.standard.integer(forKey: extensionIndexUserDefaultKey)
        self.extensions = extensionsArr[self.extensionsIndex]
    }
    
    
    func sendClientDataToIOT(userInfo: DeviceTelemetry, completion: @escaping (Result<Void, Error>) -> Void) {
        
        self.updateValueFromUserDefaults()
        let urlString = "\(iotHubName)/devices/\(iotDeviceID)/messages/events?api-version=2021-04-12"
      //  let testingURLString = "https://WatchHP.azure-devices.net/devices/watch1/messages/events?api-version=2021-04-12"
      //  let newTestingSAS = "SharedAccessSignature sr=WatchHP.azure-devices.net%2Fdevices%2Fwatch1&sig=YgXLt8dSjJQ9LUoMfqK85Hh%2BuCOL%2FyUNPCKfHCDVbMY%3D&se=1727511936"
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
    
    //MARK: - storage
    
    
    func sendDataToStorage(userInfo: DeviceTelemetry, completion: @escaping (Bool) -> Void){
        let fileName = CommonClass.createJSONFile(from: userInfo)
        
        self.createAndUploadFile(fileName: fileName ) { result in
            switch result {
            case true:
                completion(true)
            case false:
                completion(false)
            }
        }
    }
    
    
    
    private func createAndUploadFile(fileName: String, completion: @escaping (Bool) -> Void) {
        
        let accountName = UserDefaults.standard.string(forKey: storageAccountNameDefaultsKey)
        let shareName = UserDefaults.standard.string(forKey: fileShareNameDefaultsKey)
        var sasToken = UserDefaults.standard.string(forKey: sasTokenDefaultsKey)
        let sasTokenOld = UserDefaults.standard.string(forKey: sasTokenOldDefaultsKey)
        
        // Check if SAS token is empty
        guard let sasToken = sasToken, !sasToken.isEmpty, let accountNamee = accountName, !accountNamee.isEmpty, let extensionss = extensions, !extensionss.isEmpty, let shareNamee = shareName, !shareNamee.isEmpty else {
            print("SAS Token is empty. Cannot upload file.")
            return
        }
        
        guard let fileContent = readJsonFromFile(fileName: fileName) else { return }
        
        var contentLength = String(fileContent.count)
        
        let urlString = "https://\(accountName!).file.core.\(extensions ?? "").net/\(shareName!)/\(fileName)?\(sasToken)"
        
        var request = URLRequest(url: URL(string: urlString)!,timeoutInterval: Double.infinity)
        request.addValue("file", forHTTPHeaderField: "x-ms-type")
        request.addValue(contentLength, forHTTPHeaderField: "x-ms-content-length")
        request.httpMethod = "PUT"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("File creation failed")
                if let sasTokenOld = sasTokenOld, !sasTokenOld.isEmpty {
                    print("Trying with old SAS token")
                    // Retry with old SAS token
                    self.createAndUploadFileWithOldSASToken(fileName: fileName, fileContent: fileContent, completion: {  result in
                        switch result {
                        case true:
                            completion(true)
                        case false:
                            completion(false)
                        }
                    })
                }
                completion(false)
                return
            }
            var httpRes = response as? HTTPURLResponse
            var statusCode = httpRes?.statusCode
            print(statusCode, "current status code")
            
            print("Old File created successfully ++++++++ old file Sended  ++++++++")
            contentLength = String(fileContent.count - 1)
            self.uploadFile(fileName: fileName, fileContent: fileContent, contentLength: contentLength ){ result in
                switch result {
                case true:
                    completion(true)
                case false:
                    completion(false)
                }
            }
        }
        task.resume()
    }
    
    
    private func createAndUploadFileWithOldSASToken(fileName: String, fileContent: String, completion: @escaping (Bool) -> Void) {
        
        let accountName = UserDefaults.standard.string(forKey: storageAccountNameDefaultsKey)
        let shareName = UserDefaults.standard.string(forKey: fileShareNameDefaultsKey)
        var sasToken = UserDefaults.standard.string(forKey: sasTokenDefaultsKey)
        let sasTokenOld = UserDefaults.standard.string(forKey: sasTokenOldDefaultsKey)
        
        
        guard let accountNamee = accountName, !accountNamee.isEmpty, let extensionss = extensions, !extensionss.isEmpty, let shareNamee = shareName, !shareNamee.isEmpty else {
            print("SAS Token is empty. Cannot upload file.")
            completion(false)
            return
        }
        

        var contentLength = String(fileContent.count)
        
        let urlString = "https://\(accountName!).file.core.\(extensions ?? "").net/\(shareName!)/\(fileName)?\(sasTokenOld)"
        
        var request = URLRequest(url: URL(string: urlString)!,timeoutInterval: Double.infinity)
        request.addValue("file", forHTTPHeaderField: "x-ms-type")
        request.addValue(contentLength, forHTTPHeaderField: "x-ms-content-length")
        request.httpMethod = "PUT"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("File creation failed with old SAS token")
                completion(false)
                return
            }
            print("Old File created successfully with old SAS token")
            sasToken = sasTokenOld
            UserDefaults.standard.set(sasToken, forKey: sasTokenDefaultsKey)
            contentLength = String(fileContent.count - 1)
            self.uploadFile(fileName: fileName, fileContent: fileContent, contentLength: contentLength ){ result in
                switch result {
                case true:
                    completion(true)
                case false:
                    completion(false)
                }
            }
        }
        task.resume()
    }
    
    
    private func uploadFile(fileName: String, fileContent: String, contentLength: String, completion: @escaping (Bool) -> Void ) {
        
        let accountName = UserDefaults.standard.string(forKey: storageAccountNameDefaultsKey)
        let shareName = UserDefaults.standard.string(forKey: fileShareNameDefaultsKey)
        var sasToken = UserDefaults.standard.string(forKey: sasTokenDefaultsKey)
        let sasTokenOld = UserDefaults.standard.string(forKey: sasTokenOldDefaultsKey)
        

        let client = URLSession.shared
        let mediaType = "text/plain"
        let postData = fileContent.data(using: .utf8)
     
        let urlString = "https://\(accountName!).file.core.\(extensions ?? "").net/\(shareName!)/\(fileName)?\(sasToken!)&comp=range"
        var request = URLRequest(url: URL(string: urlString)!,timeoutInterval: Double.infinity)
        request.addValue("file", forHTTPHeaderField: "x-ms-type")
        request.addValue("update", forHTTPHeaderField: "x-ms-write")

        request.addValue("bytes=0-\(contentLength)", forHTTPHeaderField: "x-ms-range")
        request.addValue(mediaType, forHTTPHeaderField: "Content-Type")

        request.httpMethod = "PUT"
        request.httpBody = postData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard data != nil else {
                print(String(describing: error))
                completion(false)
                return
            }
            guard let httpResponce = response as? HTTPURLResponse, httpResponce.statusCode == 201 else {
                completion(false)
                return
            }
            completion(true)
            print("**** Old File uploaded")
        }

        task.resume()

    }
    
    private func readJsonFromFile(fileName: String) -> String? {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName)
        do {
            let contents = try String(contentsOf: fileURL!, encoding: .utf8)
            return contents
        } catch {
            print(error)
            return nil
        }
    }
    
}

extension IoTHubClient {
    
    static let watch5SASToken = "SharedAccessSignature sr=AppleWatch.azure-devices.us%2Fdevices%2Fwatch5&sig=KuazUmp4j2Gvf60SY773VA9mkfcXo3CqajnHI7I8ap0%3D&se=1754680760"
    static let watch5DeviceID = "watch5"
    static let huBName = "https://AppleWatch.azure-devices.us"
    
}
