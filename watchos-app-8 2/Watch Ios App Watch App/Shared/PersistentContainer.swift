//
//  PersistentContainer.swift
//  QP HT Applicationn
//
//  Created by Hastree on 23.07.2024.
//

import CoreData


final class PersistentContainer {
    
    private init() {}
    static let shared = PersistentContainer()
    let minAllowedStorageSize: Int64 = 5 * 1024 * 1024 * 1024
    
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "CoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }else{
                if let url = storeDescription.url {
                    print("SQLite file path: \(url.path)")
                }
            }
        })
        return container
    }()
    
    
    lazy var context = persistentContainer.viewContext
    
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
                print("Data are saving...")
            } catch {
                
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        let backgroundContext = persistentContainer.newBackgroundContext()
        return backgroundContext
    }
    
}
