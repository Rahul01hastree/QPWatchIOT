//
//  LocaldataProcessor.swift
//  QP HT Applicationn
//
//  Created by Rahul Gangwar on 31.08.2024.
//

import Foundation

class LocaldataProcessor {
    
    // Singleton for DataProcessor
    static let shared = LocaldataProcessor()
    private let maxDeleteRetryAttempts = 3
    private let userDefaultsKey = "currentDeviceIndex"
    private var count:Int = 0
    
    private init() { }
    
    // Function to start processing data
    func processAndSendData() {
        fetchAndSendNextLocation()
    }
    
    private func fetchAndSendNextLocation() {
        DispatchQueue.global(qos: .background).async {
            // Fetch the single stored location
            guard let userDatum = CoredataManager.shared.fetchSingleStoredLocation() else {
                // No more data to process
                print("No more data to process.")
                return
            }
            self.count += 1
            print("\(self.count), number of time data deleted. current local data count :- \(CoredataManager.shared.fetchStoredLocations().count)")
            
            // Simulate sending data to Azure
            self.sendCoreDataBasedOnUserSelection(unitBatch: userDatum)
    
        }
    }
    
    private func sendCoreDataBasedOnUserSelection(unitBatch: UserInfo) {
           let selectedDeviceIndex = UserDefaults.standard.integer(forKey: userDefaultsKey)
           
           let sendCompletion: (Bool) -> Void = { result in
               if result {
                   self.deleteRecordAndContinue(userDatum: unitBatch, retryCount: 0)
               } else {
                   self.fetchAndSendNextLocation()  // Continue fetching the next record
               }
           }
           
           if selectedDeviceIndex == 0 {
               sendBatchToIOTHUBTest(batch: unitBatch, completion: sendCompletion)
           } else {
               sendToStorage(batch: unitBatch, completion: sendCompletion)
           }
       }
    
    
    
//    func sendCoreDataBasedOnUserSelection(unitBatch: UserInfo){
//        let selectedDeviceIndex = UserDefaults.standard.integer(forKey: "currentDeviceIndex")
//        //0 for azure IOT
//        //1 for azure STORAGE
//        
//        if selectedDeviceIndex == 0 {
//            sendBatchToIOTHUBTest(batch: unitBatch ){ result in
//                if result {
//                    CoredataManager.shared.deleteSingleRecord(userLocation: unitBatch ){ result in
//                        if result{
//                            print("Successfully deleted record after sending data to IOT.")
//                           
//                        }
//                        self.fetchAndSendNextLocation()
//                        
//                    }
//                }else{
//                    self.fetchAndSendNextLocation()
//                }
//                
//            }
//        }else{
//            sendToStorage(batch: unitBatch ){ result in
//                if result {
//                    CoredataManager.shared.deleteSingleRecord(userLocation: unitBatch ){ result in
//                        if result {
//                            if result{
//                                print("Successfully deleted record after sending data to STORAGE.")
//                               
//                            }
//                            self.fetchAndSendNextLocation()
//                        }
//                    }
//                }else{
//                    self.fetchAndSendNextLocation()
//                }
//            }
//        }
//        
//        
//    }
    
    
    private func sendBatchToIOTHUBTest(batch: UserInfo, completion: @escaping (Bool) -> Void) {
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            // Simulate network delay
            let data = DeviceTelemetry(deviceID: currDeviceID,
                                       longitude: batch.longitude,
                                       latitude: batch.latitude,
                                       batteryLevel: batch.batteryLevel,
                                       speed:batch.speed ?? "",
                                       direction: batch.direction ?? "",
                                       timeandDate: batch.timeStamp ?? "",
                                       isOldData: true
            )
            
            IoTHubClient.shared.sendClientDataToIOT(userInfo: data) { result in
                switch result {
                case .success:
                    print("data is sended to old data IOT ******** ")
                    completion(true)
                case .failure:
                    print("STORAGE failure")
                    completion(false)
                }
            }
        }
    }
    
    private func sendToStorage(batch : UserInfo, completion: @escaping (Bool) -> Void){
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            let data = DeviceTelemetry(deviceID: currDeviceID,
                                       longitude: batch.longitude,
                                       latitude: batch.latitude,
                                       batteryLevel: batch.batteryLevel,
                                       speed:batch.speed ?? "",
                                       direction: batch.direction ?? "",
                                       timeandDate: batch.timeStamp ?? "",
                                       isOldData: true
            )
            IoTHubClient.shared.sendDataToStorage(userInfo: data ) { result in
                switch result {
                case true:
                    print("data is sended to old data STORAGE ++++++ ")
                    completion(true)
                case false:
                    print("STORAGE failure")
                    completion(false)
                }
            }
        }
        
    }
    
    private func deleteRecordAndContinue(userDatum: UserInfo, retryCount: Int) {
          CoredataManager.shared.deleteSingleRecord(userLocation: userDatum) { result in
              if result {
                  print("Successfully deleted record after sending data.")
                  self.fetchAndSendNextLocation()  // Continue fetching the next record
              } else {
                  print("Failed to delete the record. Retry count: \(retryCount)")
                  
                  if retryCount < self.maxDeleteRetryAttempts {
                      // Retry deleting the record
                      DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                          self.deleteRecordAndContinue(userDatum: userDatum, retryCount: retryCount + 1)
                      }
                  } else {
                      print("Exceeded maximum retry attempts for deleting record.")
                      self.fetchAndSendNextLocation()  // Continue fetching the next record
                  }
              }
          }
      }
    
}
