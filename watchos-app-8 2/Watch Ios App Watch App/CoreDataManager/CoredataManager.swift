//
//  CoredataManager.swift
//  QP HT Applicationn
//
//  Created by Rahul Gangwar on 31.08.2024.
//

import Foundation
import CoreData
import CoreLocation

class CoredataManager: NSObject, NSFetchedResultsControllerDelegate {
    
    static let shared = CoredataManager()
    private let persistentContainer = PersistentContainer.shared
    
    private override init() { }
    
    // Fetched Results Controller
    lazy var fetchedResultsController: NSFetchedResultsController<UserInfo> = {
        let fetchRequest: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: true)]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: persistentContainer.context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        controller.delegate = self
        
        do {
            try controller.performFetch()
        } catch {
            print("Failed to initialize FetchedResultsController: \(error)")
        }
        
        return controller
    }()
    
    
    func saveUserIntoToLocally(location: CLLocation, with direction: String? = ""){
        
        var userId = CommonClass.getDeviceID().uuidString
        var deviceBatteryPercentage = abs(CommonClass.updateBatteryLevel())
        var latitude = location.coordinate.latitude
        var longitude = location.coordinate.longitude
        var speed: Double
        var speedInMiles: String = ""
        if location.speed * 0.000621371 <= 0 {
            speed = 0.0000
            speedInMiles = String(format: "%.2f", speed)
        }
        else{
            speed = location.speed * 0.000621371
            speedInMiles = String(format: "%.2f", speed)
        }
        var currentTime = CommonClass.getCurrrentDateTime()
        
        self.saveLocationData(latitude: latitude, longitude: longitude, batteryLevel: deviceBatteryPercentage, deviceID: userId , speed: speedInMiles, direction: direction ?? "", timeStamp: currentTime)
        
    }
    
    func clearCoreDataWhenFilled(limit: Int, newLocation: CLLocation){
        self.deleteFixRecords(deletionLimit: limit, newLocation: newLocation )
    }
    
    
    // Save Location Data
    private func saveLocationData(latitude: Double, longitude: Double, batteryLevel: Float, deviceID: String, speed: String, direction: String, timeStamp: String) {
        let context = persistentContainer.context
        context.perform {
            let userInfo = UserInfo(context: context)
            userInfo.timeStamp = timeStamp
            userInfo.batteryLevel = batteryLevel
            userInfo.deviceID = deviceID
            userInfo.direction = direction
            userInfo.latitude = latitude
            userInfo.longitude = longitude
            userInfo.speed = speed
            self.persistentContainer.saveContext()
        }
        
    }
    
    private func deleteFixRecords(deletionLimit: Int, newLocation: CLLocation) {
            let context = persistentContainer.context
            context.perform {
                let fetchRequest: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
                fetchRequest.fetchLimit = deletionLimit
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: true)]
                
                do {
                    let recordsToDelete = try context.fetch(fetchRequest)
                    for record in recordsToDelete {
                        context.delete(record)
                    }
                    try context.save()
                    self.saveUserIntoToLocally(location: newLocation )
                    print("Successfully deleted 100 records.")
                } catch {
                    print("Failed to delete 100 records: \(error)")
                }
            }
        }
    
    
    // Delete a Single Record
    func deleteSingleRecord(userLocation: UserInfo, completion: @escaping (Bool) -> Void) {
        let context = persistentContainer.context
        context.perform {
            // Ensure the object is in the same context before deleting
            if context.object(with: userLocation.objectID) == userLocation {
                context.delete(userLocation)
                do {
                    try context.save()
                    DispatchQueue.main.async {
                        completion(true)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    // Fetch All Stored Locations
    func fetchStoredLocations() -> [UserInfo] {
        return fetchedResultsController.fetchedObjects ?? []
    }
    
    // Fetch Single Stored Location
    func fetchSingleStoredLocation() -> UserInfo? {
        return fetchedResultsController.fetchedObjects?.first
    }

    
}


extension CoredataManager {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("Object inserted at \(String(describing: newIndexPath))")
        case .delete:
            print("Object deleted at \(String(describing: indexPath))")
        case .update:
            print("Object updated at \(String(describing: indexPath))")
        case .move:
            print("Object moved from \(String(describing: indexPath)) to \(String(describing: newIndexPath))")
        @unknown default:
            fatalError("Unknown change type encountered.")
        }
    }
}
