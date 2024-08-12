//
//  LocationDataBatchProcessor.swift
//  QP HT Applicationn
//
//  Created by Rahul Gangwar on 12.08.2024.
//

import Foundation
import CoreData
import WatchKit

class LocationDataBatchProcessor {
    
    private let batchProcessingSemaphore = DispatchSemaphore(value: 1)
    private let persistentContainer: NSPersistentContainer
    private var isProcessingBatches = false
    
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
            
//            for (index, batch) in batches.enumerated() {
//                self.sendBatchToIOTHUB(batch: batch) {
//                    print("Batch \(index + 1) sent successfully.")
//                    if index == batches.count - 1 {
//                        self.batchProcessingSemaphore.signal()  // Signal the semaphore when done
//                    }
//                }
//            }
        }
    }
}

