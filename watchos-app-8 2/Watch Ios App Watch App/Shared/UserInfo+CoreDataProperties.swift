//
//  UserInfo+CoreDataProperties.swift
//  QP HT Applicationn
//
//  Created by Hastree on 23.07.2024.
//
//

import Foundation
import CoreData


extension UserInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserInfo> {
        return NSFetchRequest<UserInfo>(entityName: "UserInfo")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var batteryLevel: Float
    @NSManaged public var deviceID: String?
    @NSManaged public var speed: String?
    @NSManaged public var direction: String?
    @NSManaged public var timeStamp: String?

}

extension UserInfo : Identifiable {

}
