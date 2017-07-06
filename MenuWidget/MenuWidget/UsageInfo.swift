//
//  UsageInfo.swift
//  MenuWidget
//
//  Created by Jonah U on 6/6/17.
//  Copyright © 2017 Jonah U. All rights reserved.
//

import Foundation
import CoreData

class UsageInfo {
    
    let coreDataStack = CoreDataStack()
    let defaults = UserDefaults.standard
    
    var started : Date? = nil
    var ended : Date? = nil
    
    var currentlyDownTime: Bool {
        return started != nil && ended == nil
    }
    var downTimeEnded: Bool {
        return started != nil && ended != nil
    }

    //MARK: - methods
    
    func fetchRecentData(_ filter: Int, success: @escaping ([UsageData]) -> Void){
        if let recentData = self.fetchRecentData(filter){
            success(recentData)
        }else{
            NSLog("Error: problem with fetching DownTime data")
        }
    }
    func saveData(){
        if downTimeEnded {
            let managedContext = coreDataStack.persistentContainer.viewContext
            let usageRecord = UsageData(context: managedContext)
        
            usageRecord.startTime = started!
            usageRecord.endTime = ended!
            usageRecord.setTimeInverval()
            
            //Reseting values for next set of data
            started = nil
            ended = nil
            
            do {
                //Save Changes
                try managedContext.save()
                defaults.set(true, forKey:"SavedDataExists")
            } catch let error{
                //Error Handling
                print("Error registering new DownTime data: \(error)")
            }
        } else {
            print("Illegal DownTime data save attempt")
            started = nil
            ended = nil
        }
    }
    
    func fetchRecentData(_ filter: Int)-> [UsageData]? {
        let managedContext = coreDataStack.persistentContainer.viewContext
        var recentData = [UsageData]()
        
        do{
            let results = try managedContext.fetch(UsageData.fetchRequest()) as! [UsageData]
            
            var arraySize : Int = filter
            if results.count < filter{
                arraySize = results.count
            }
            
            for i in 0 ..< arraySize{
                recentData.append(results[results.count - 1 - i])
            }
            print("\(results.count) records")
            defaults.set(results.count, forKey:"DataRecordsCount")
            return recentData
        }catch{
            print("Data fetching error:\(error)")
            return nil
        }
    }
    
    func fetchAllData() {
        let managedContext = coreDataStack.persistentContainer.viewContext
        do{
            let results = try managedContext.fetch(UsageData.fetchRequest()) as! [UsageData]
            
            for result in results{
                if let _ = result.endTime{
                    print("time: \(result.endTime), timeInterval: \(result.timeInterval)")
                }
            }
        }catch{
            print("Fetching error:\(error)")
        }
    }
    
    func toggleDownTime(_ aNotification : NSNotification){
        if aNotification.name == NSNotification.Name.NSWorkspaceWillSleep{
            started = Date()
        }else if aNotification.name == NSNotification.Name.NSWorkspaceDidWake && currentlyDownTime{
            ended = Date()
            saveData()
        }else{
            NSLog("Error: problem recording values")
            started = nil
            ended = nil
        }
    }
    
    func deleteData(){
        let managedContext = coreDataStack.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<UsageData> = UsageData.fetchRequest()
        
        do{
            let array = try managedContext.fetch(fetchRequest)
            
            for data in array as [UsageData] {
                managedContext.delete(data)
            }
            do{
               try managedContext.save()
                defaults.set(false, forKey:"SavedDataExists")
                defaults.set(0, forKey:"DataRecordsCount")
            } catch let error as NSError {
                print("Saving error:\(error), \(error.userInfo)")
            } catch {
                
            }
            
        } catch {
            print ("Error with request:\(error)")
        }
    }
}



