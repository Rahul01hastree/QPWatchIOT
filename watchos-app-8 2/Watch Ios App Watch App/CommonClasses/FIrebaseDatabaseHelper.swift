//
//  FIrebaseHelperClass.swift
//  QP HT Applicationn
//
//  Created by Apps we love on 22/03/24.
//

import Foundation

class FirebaseDatabaseHelper {
    
    func fetchDataFromFirebase() {
        guard let url = URL(string: "https://qp-apple-watch-tracker-app-default-rtdb.firebaseio.com/.json") else {
            print("Invalid Firebase Database URL")
            return
        }
        print("we got success in fetching data from firebase.")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let jsonDict = json as? [String: Any] {
                    self.storeIntoUserDefulats(from: jsonDict)
                    DispatchQueue.main.async {
                        if isSasTokenRefreshBtbTapped {
                            self.updateSasToken(with: jsonDict)
                            isSasTokenRefreshBtbTapped = false
                        }
                        if isStorageAndFileNameRefreshBtnTapped {
                            self.updateStorageAndFilesNamesArrs(with: jsonDict)
                            isStorageAndFileNameRefreshBtnTapped = false
                        }
                        print(jsonDict)
                    }
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func updateSasToken(with data: [String: Any]){
        if sasTokenNew != "" {
            sasTokenOld = sasTokenNew
            sasTokenNew = data["SAS Token"] as? String ?? ""
            UserDefaults.standard.set(sasTokenNew, forKey: sasTokenDefaultsKey)
            UserDefaults.standard.set(sasTokenOld, forKey: sasTokenOldDefaultsKey)
        }else{
            sasTokenNew = data["SAS Token"] as? String ?? ""
            UserDefaults.standard.set(sasTokenNew, forKey: sasTokenDefaultsKey)
        }
    }
    
    func updateStorageAndFilesNamesArrs(with data: [String: Any]) {
         
        storageAccountNamesArr.removeAll()
        fileShareNamesArr.removeAll()
        
        if let storageAccountOptions = data["Storage Account options"] as? [String: String] {
            for (_, storageAccountName) in storageAccountOptions {
                storageAccountNamesArr.append(storageAccountName)
            }
            UserDefaults.standard.set(storageAccountNamesArr, forKey: storageAccountNamesArrayDefaultsKey)
        }
        
        if let fileShareNameOptions = data["fileShareName"] as? [String: String] {
            for (_, fileShareName) in fileShareNameOptions {
                fileShareNamesArr.append(fileShareName)
            }
            UserDefaults.standard.set(fileShareNamesArr, forKey: fileShareNamesArrayDefaultsKey)
        }
        
    }
    
    
    private func storeIntoUserDefulats(from jsonData : [String: Any] ){
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonData, options: [])
            UserDefaults.standard.set(data, forKey: "userINFO")
            print("JSON data successfully stored in UserDefaults.")
        } catch {
            print("Error serializing JSON: \(error)")
        }
    }
    
    
    
    
}
