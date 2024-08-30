import Foundation
import CoreData
import WatchKit

class LocationDataBatchProcessor {
    
    private let batchProcessingSemaphore = DispatchSemaphore(value: 1)
    private let persistentContainer: NSPersistentContainer
    
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    func processStoredLocationsInBatches(batchSize: Int = 10) {
        DispatchQueue.global(qos: .background).async {
            self.batchProcessingSemaphore.wait()  // Wait for the semaphore
            
            let userStoredLocations = CoreDataHelper.shared.fetchStoredLocations()
            guard !userStoredLocations.isEmpty else {
                self.batchProcessingSemaphore.signal()
                return
            }
            
            let batches = stride(from: 0, to: userStoredLocations.count, by: batchSize).map {
                Array(userStoredLocations[$0..<min($0 + batchSize, userStoredLocations.count)])
            }
            
            var batchesProcessed = 0
            
            for batch in batches {
                self.sendBatchToIOTHUB(batch: batch) { success in
                    if success {
                        print("Batch sent successfully.")
                        self.deleteSentRecords(batch: batch)
                    }
                    
                    batchesProcessed += 1
                    if batchesProcessed == batches.count {
                        self.batchProcessingSemaphore.signal()
                        self.processStoredLocationsInBatches(batchSize: batchSize) // Recurse to process next batches
                    }
                }
            }
        }
    }
    
    private func sendBatchToIOTHUB(batch: [UserInfo], completion: @escaping (Bool) -> Void) {
        let data = DeviceTelemetry(deviceID: currDeviceID,
                                   longitude: batch[0].longitude,
                                   latitude: batch[0].latitude,
                                   batteryLevel: batch[0].batteryLevel,
                                   speed:batch[0].speed ?? "",
                                   direction: batch[0].direction ?? "",
                                   timeandDate: batch[0].timeStamp ?? ""
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
    
    private func deleteSentRecords(batch: [UserInfo]) {
        let context = persistentContainer.viewContext
        let userStoredLocations = CoreDataHelper.shared.fetchStoredLocations()
        print(userStoredLocations.count)
        batch.forEach { userInfo in
            context.delete(userInfo)
        }
        
        do {
            print(userStoredLocations.count)
            print("to delete sent records :----- ")
            try context.save()
        } catch {
            print("Failed to delete sent records: \(error)")
        }
    }
}
