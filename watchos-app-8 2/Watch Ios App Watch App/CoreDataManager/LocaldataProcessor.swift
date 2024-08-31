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
            print("\(self.count), number of time data deleted. current local data count :- \(CoredataManager.shared.fetchStoredLocations().count)")
            // Simulate sending data to IoT Hub
            self.sendBatchToIOTHUBTest(batch: userDatum) { result in
                if result {
                    // On successful sending, delete the record
                    CoredataManager.shared.deleteSingleRecord(userLocation: userDatum) { deletionSuccess in
                        if deletionSuccess {
                            print("Successfully deleted record after sending data.")
                            // Recursively fetch and process the next record
                            self.fetchAndSendNextLocation()
                        } else {
                            print("Failed to delete record after sending data.")
                            // Handle the deletion failure scenario if needed
                            self.fetchAndSendNextLocation()
                        }
                    }
                } else {
                    print("Failed to send data to IoT Hub.")
                    // Handle the sending failure scenario if needed
                    self.fetchAndSendNextLocation()
                }
            }
        }
    }
    
    private func sendBatchToIOTHUBTest(batch: UserInfo, completion: @escaping (Bool) -> Void) {
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            // Simulate network delay
            let data = DeviceTelemetry(deviceID: currDeviceID,
                                       longitude: batch.longitude,
                                       latitude: batch.latitude,
                                       batteryLevel: batch.batteryLevel,
                                       speed:batch.speed ?? "",
                                       direction: batch.direction ?? "",
                                       timeandDate: batch.timeStamp ?? ""
            )
            
            IoTHubClient.shared.sendClientDataToIOT(userInfo: data) { result in
                switch result {
                case .success:
                    completion(true)
                case .failure:
                    completion(false)
                }
            }
        }
    }
    
}
