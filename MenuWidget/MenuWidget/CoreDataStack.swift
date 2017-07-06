//
//  CoreDataStack.swift
//  MenuWidget
//
//  Created by Jonah U on 6/13/17.
//  Copyright © 2017 Jonah U. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DownTimeModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                //fatalError("Unresolved error \(error), \(error.userInfo)")
                print("Unresolved CoreData container error:\(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges{
            do{
                try context.save()
            }catch{
                let error = error as NSError
                fatalError("CoreData save error:\(error), \(error.userInfo)")
            }
        }
    }
    
    func deleteSavedData(){
        let context = persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "UsageData")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do{
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            let error = error as NSError
            print ("CoreData error:\(error) when attempting to delete all records, \(error.userInfo)")
        }
    }
}
