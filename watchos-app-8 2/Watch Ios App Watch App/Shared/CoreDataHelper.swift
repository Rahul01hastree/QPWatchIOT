//
//  CoreDataHelper.swift
//  QP HT Applicationn
//
//  Created by Rahul Gangwar on 12.08.2024.
//

import Foundation
import CoreLocation
import CoreData

class CoreDataHelper {
    
    static let shared =  CoreDataHelper()
    private let persistentContainer = PersistentContainer.shared
    
    init() { }
    
    
      func userInfoToLocal( location: CLLocation){
        
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
        
        self.saveLocationData(latitude: latitude, longitude: longitude, batteryLevel: deviceBatteryPercentage, deviceID: userId , speed: speedInMiles, direction: "", timeStamp: currentTime)
        
        
    }
    
    
      func saveLocationData(latitude: Double, longitude: Double, batteryLevel: Float, deviceID: String, speed: String, direction: String, timeStamp: String) {
        
        let userInfo = UserInfo(context: persistentContainer.context)
        
        userInfo.timeStamp = timeStamp
        userInfo.batteryLevel = batteryLevel
        userInfo.deviceID = deviceID
        userInfo.direction = direction
        userInfo.latitude = latitude
        userInfo.longitude = longitude
        userInfo.speed = speed
        
        persistentContainer.saveContext()
    }
    
    //MARK: - Fetch from Core Data
    
      func fetchUserInfoFromCoreData(){
        
        do {
            guard let result = try persistentContainer.context.fetch(UserInfo.fetchRequest()) as? [UserInfo] else { return }
            
            for userInfo in result {
                print("DeviceID: \(userInfo.deviceID ?? "No Name")")
                print("Time: \(userInfo.timeStamp ?? "No Email")")
                print("Long: \(userInfo.longitude)")
                print("Battery Level : \(userInfo.batteryLevel)")
                print("Speed : \(userInfo.speed ?? "")")
                print("Direction : \(userInfo.direction ?? "null")")
            }
            
        }catch (let err){
            debugPrint(err)
        }
    }
    
      func fetchStoredLocations() -> [UserInfo] {
        let fetchRequest: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
        
        do {
            let locations = try persistentContainer.context.fetch(fetchRequest)
            return locations
        } catch {
            print("Failed to fetch locations: \(error)")
            return []
        }
    }

    
    
    
    //MARK: - Delete from Core Data
    
      func delete50UserInfoEntries(location: CLLocation) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = UserInfo.fetchRequest()  // Use the fetch request defined
        fetchRequest.fetchLimit = 50  // Set the limit to 10 to fetch only 10 entries
        
        let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let context = persistentContainer.context
        do {
            let fetchedObjects = try context.fetch(fetchRequest) as! [UserInfo]
            for object in fetchedObjects {
                context.delete(object)
            }
            try context.save()
            print("Deleted 10 UserInfo entries based on oldest timeStamp.")
            self.userInfoToLocal(location: location)
        } catch {
            let nserror = error as NSError
            print("Error while deleting UserInfo entries: \(nserror), \(nserror.userInfo)")
        }
    }
    
      func deletePerticularLocationFromCoreData(location: UserInfo, index: Int) {
        let context = persistentContainer.context
        
        context.delete(location)  // Mark the object for deletion

        do {
            try context.save()  // Persist the deletion
            print("entry no \(index) +++ Last location deleted from Core Data.")
        } catch {
            print("Failed to delete location from Core Data: \(error)")
        }
    }

    
      func deleteAllEntries() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = UserInfo.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        let context = PersistentContainer.shared.context
        context.perform {
            do {
                try context.execute(deleteRequest)
                try context.save()
                print("Successfully deleted all entries.")
            } catch {
                print("Failed to delete entries: \(error)")
            }
        }
    }
    
    
    
    
    
}
