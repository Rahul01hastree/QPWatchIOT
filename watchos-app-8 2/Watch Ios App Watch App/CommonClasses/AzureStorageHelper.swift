//
//  AzureStorageHelper.swift
//  Watch Ios App Watch App
//
//  Created by Apps we love on 15/12/23.
//

import Foundation

class AzureStorageHelper {

//    private let accountName = "devicedata"
//    private let shareName = "smart-watch"
    private let accountName = UserDefaults.standard.string(forKey: storageAccountNameDefaultsKey)
    private let shareName = UserDefaults.standard.string(forKey: fileShareNameDefaultsKey)
    private var sasToken = UserDefaults.standard.string(forKey: sasTokenDefaultsKey)
    private let sasTokenOld = UserDefaults.standard.string(forKey: sasTokenOldDefaultsKey)
    private let extensionsIndex: Int
    private let extensions: String?

    init() {
        self.extensionsIndex = UserDefaults.standard.integer(forKey: extensionIndexUserDefaultKey)
        self.extensions = extensionsArr[self.extensionsIndex]
    }

    func readJsonFromFile(fileName: String) -> String? {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName)
        do {
            let contents = try String(contentsOf: fileURL!, encoding: .utf8)
            return contents
        } catch {
            print(error)
            return nil
        }
    }
    
   
    func createAndUploadFile(fileName: String) {
        // Check if SAS token is empty
        guard let sasToken = sasToken, !sasToken.isEmpty, let accountNamee = accountName, !accountNamee.isEmpty, let extensionss = extensions, !extensionss.isEmpty, let shareNamee = shareName, !shareNamee.isEmpty else {
            print("SAS Token is empty. Cannot upload file.")
            return
        }
        
        guard let fileContent = readJsonFromFile(fileName: fileName) else { return }
        
        let client = URLSession.shared
        var contentLength = String(fileContent.count)
       // let urlString = "https://\(accountNamee).file.core.\(extensionss).net/\(shareNamee)/\(fileName)\(sasToken)"
        
        let urlString = "https://\(accountName!).file.core.\(extensions ?? "").net/\(shareName!)/\(fileName)?\(sasToken)"

        var request = URLRequest(url: URL(string: urlString)!,timeoutInterval: Double.infinity)
        request.addValue("file", forHTTPHeaderField: "x-ms-type")
        request.addValue(contentLength, forHTTPHeaderField: "x-ms-content-length")
        request.httpMethod = "PUT"

        let task = client.dataTask(with: request) { data, response, error in
            guard let data = data else {
                // Handle file creation failure
                print("File creation failed")
                if let sasTokenOld = self.sasTokenOld, !sasTokenOld.isEmpty {
                    print("Trying with old SAS token")
                    // Retry with old SAS token
                    self.createAndUploadFileWithOldSASToken(fileName: fileName, fileContent: fileContent)
                }
                return
            }
            print("File created successfully")
            contentLength = String(fileContent.count - 1)
            self.uploadFile(fileName: fileName, fileContent: fileContent, contentLength: contentLength)
        }
        task.resume()
    }

    func createAndUploadFileWithOldSASToken(fileName: String, fileContent: String) {
    
        guard let accountNamee = accountName, !accountNamee.isEmpty, let extensionss = extensions, !extensionss.isEmpty, let shareNamee = shareName, !shareNamee.isEmpty else {
            print("SAS Token is empty. Cannot upload file.")
            return
        }
        
        
        let client = URLSession.shared
        var contentLength = String(fileContent.count)
    //    let urlString = "https://\(accountName!).file.core.\(extensions).net/\(shareName!)/\(fileName)\(sasTokenOld)"
        
        
        let urlString = "https://\(accountName!).file.core.\(extensions ?? "").net/\(shareName!)/\(fileName)?\(sasTokenOld)"
        
        var request = URLRequest(url: URL(string: urlString)!,timeoutInterval: Double.infinity)
        request.addValue("file", forHTTPHeaderField: "x-ms-type")
        request.addValue(contentLength, forHTTPHeaderField: "x-ms-content-length")
        request.httpMethod = "PUT"

        let task = client.dataTask(with: request) { data, response, error in
            guard let data = data else {
                // Handle file creation failure with old SAS token
                print("File creation failed with old SAS token")
                return
            }
            print("File created successfully with old SAS token")
            self.sasToken = self.sasTokenOld
            UserDefaults.standard.set(self.sasToken, forKey: sasTokenDefaultsKey)
            contentLength = String(fileContent.count - 1)
            self.uploadFile(fileName: fileName, fileContent: fileContent, contentLength: contentLength)
        }
        task.resume()
    }
    
    
    private func uploadFile(fileName: String, fileContent: String, contentLength: String) {
        
        let client = URLSession.shared
        let mediaType = "text/plain"
        let postData = fileContent.data(using: .utf8)
        //let contentLength = String(fileContent.count-1)
      // print(postData as Any)
        let urlString = "https://\(accountName!).file.core.\(extensions ?? "").net/\(shareName!)/\(fileName)?\(sasToken!)&comp=range"
        var request = URLRequest(url: URL(string: urlString)!,timeoutInterval: Double.infinity)
        request.addValue("file", forHTTPHeaderField: "x-ms-type")
        request.addValue("update", forHTTPHeaderField: "x-ms-write")
//        request.addValue("bytes=0-"+contentLength, forHTTPHeaderField: "x-ms-range")
     //   print("bytes=0-\(contentLength)")
        request.addValue("bytes=0-\(contentLength)", forHTTPHeaderField: "x-ms-range")
        request.addValue(mediaType, forHTTPHeaderField: "Content-Type")

        request.httpMethod = "PUT"
        request.httpBody = postData

        let task = client.dataTask(with: request) { data, response, error in
            guard data != nil else {
                print(String(describing: error))
                return
            }
        
            print("****File uploaded")
        }

        task.resume()

    }

    private func deleteFileFromFilesDir(fileName: String) -> Bool {
        guard let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName) else { return false }
        do {
            try FileManager.default.removeItem(at: fileURL)
            return true
        } catch {
        
            return false
        }
    }
}





//var request = URLRequest(url: URL(string: "https://\(accountName).file.core.usgovcloudapi.net/\(shareName)/\(fileName)?sv=2022-11-02&ss=f&srt=sco&sp=rwlc&se=2030-12-27T22%3A09%3A30Z&st=2023-12-27T14%3A09%3A30Z&spr=https&sig=NIx0UA3rDj8z8%2FDQGOd%2BG713kBNCFd6L9m6rcgoarkk%3D")!,timeoutInterval: Double.infinity)
       
//var request = URLRequest(url: URL(string: "https://\(accountName).file.core.usgovcloudapi.net/\(shareName)/\(fileName)?sv=2022-11-02&ss=f&srt=sco&sp=rwlc&se=2030-12-27T22%3A09%3A30Z&st=2023-12-27T14%3A09%3A30Z&spr=https&sig=NIx0UA3rDj8z8%2FDQGOd%2BG713kBNCFd6L9m6rcgoarkk%3D&comp=range")!,timeoutInterval: Double.infinity)
