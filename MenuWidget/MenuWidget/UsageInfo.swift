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
    
    func fetchCalculatedData(filter: Int, hours: Int, success: @escaping (TimeInterval) -> Void){
        if let total = self.calculateData(filter, hours){
            success(total)
        }else{
            NSLog("Error: problem with fetching calculated DownTime data")
        }
    }
    
    func calculateData(_ filter: Int, _ hours: Int) -> TimeInterval?{
        let now = Date()
        let interval : TimeInterval = TimeInterval(-hours * 3600) //3600 seconds in 1 hour
        let earlierDate = now.addingTimeInterval(interval)
        var total : TimeInterval = 0
        
        if let dataArray = fetchRecentDataNoIgnore(filter){
        
            for data in dataArray{
                if (data.startTime?.timeIntervalSinceNow)! <= interval{
                    if data.endTime! > earlierDate{
                        let split : TimeInterval = data.endTime!.timeIntervalSince(earlierDate)
                        total += split
                    }
                    break
                }
                total += data.timeInterval
            }
            return total
            
        }else{
            return 0
        }
    }
    
    func saveData(){ //not power data
        if downTimeEnded {
            let managedContext = coreDataStack.persistentContainer.viewContext
            let usageRecord = UsageData(context: managedContext)
            
            usageRecord.startTime = started!
            usageRecord.endTime = ended!
            usageRecord.setTimeInverval()
            usageRecord.isPowerOffData = false
            usageRecord.dataType = "sleep"
            
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

    
    func saveData(isPowerData : Bool, type : String){
        if downTimeEnded {
            let managedContext = coreDataStack.persistentContainer.viewContext
            let usageRecord = UsageData(context: managedContext)
            
            usageRecord.startTime = started!
            usageRecord.endTime = ended!
            usageRecord.setTimeInverval()
            usageRecord.isPowerOffData = isPowerData
            usageRecord.dataType = type
            
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
            
            let savedIgnorePref = defaults.double(forKey: "IgnorePref")

            for i in 0 ..< arraySize{
                if (results[results.count - 1 - i].timeInterval > savedIgnorePref){
                    recentData.append(results[results.count - 1 - i])
                }
            }
            
            defaults.set(results.count, forKey:"DataRecordsCount")
            return recentData
        }catch{
            print("Data fetching error:\(error)")
            return nil
        }
    }
    
    func fetchRecentDataNoIgnore(_ filter: Int)-> [UsageData]? {
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
            
            return recentData
        }catch{
            print("Data fetching error:\(error)")
            return nil
        }
    }

    
    //not used
    func printAllData() {
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
        if aNotification.name == NSNotification.Name.NSWorkspaceWillSleep || aNotification.name == NSNotification.Name.NSWorkspaceSessionDidResignActive{
            started = Date()
        }else if aNotification.name == NSNotification.Name.NSWorkspaceDidWake && currentlyDownTime{
            ended = Date()
            saveData()
        }else if aNotification.name == NSNotification.Name.NSWorkspaceSessionDidBecomeActive{
            ended = Date()
            saveData(isPowerData: true, type: "session")
        }else{
            NSLog("Error: problem recording values")
            started = nil
            ended = nil
        }
    }
    
    func recordPowerOffTime(start: Date, end: Date){
        started = start
        ended = end
        saveData(isPowerData : true, type: "power")
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
    
/*    func toggleFakeTime(){
        //yesterday 25hrs
        let userCalendar = Calendar.current
        var date1 = DateComponents()
        date1.year = 2017
        date1.month = 8
        date1.day = 01
        date1.hour = 10
        date1.minute = 0
        let date1Date = userCalendar.date(from: date1)
        print("date1: \(date1Date)")
        
        var date2 = DateComponents()
        date2.year = 2017
        date2.month = 8
        date2.day = 02
        date2.hour = 17
        date2.minute = 20
        let date2Date = userCalendar.date(from: date2)
        print("date2: \(date2Date)")
        
        started = date1Date
        ended = date2Date
        saveData()

        

        //today 12:10-6:30
        var date3 = DateComponents()
        date3.year = 2017
        date3.month = 8
        date3.day = 3
        date3.hour = 0
        date3.minute = 10
        let date3Date = userCalendar.date(from: date3)
        print("date3: \(date3Date)")
        
        var date4 = DateComponents()
        date4.year = 2017
        date4.month = 8
        date4.day = 3
        date4.hour = 6
        date4.minute = 30
        let date4Date = userCalendar.date(from: date4)
        print("date4: \(date4Date)")
        
        started = date3Date
        ended = date4Date
        saveData()
        
        //8-9
        var date5 = DateComponents()
        date5.year = 2017
        date5.month = 8
        date5.day = 3
        date5.hour = 8
        date5.minute = 0
        let date5Date = userCalendar.date(from: date5)
        print("date5: \(date5Date)")
        
        var date6 = DateComponents()
        date6.year = 2017
        date6.month = 8
        date6.day = 3
        date6.hour = 9
        date6.minute = 10
        let date6Date = userCalendar.date(from: date6)
        print("date6: \(date6Date)")
        
        started = date5Date
        ended = date6Date
        saveData()

        //10:12-10:16
        var date7 = DateComponents()
        date7.year = 2017
        date7.month = 8
        date7.day = 3
        date7.hour = 10
        date7.minute = 12
        let date7Date = userCalendar.date(from: date7)
        print("date7: \(date7Date)")
        
        var date8 = DateComponents()
        date8.year = 2017
        date8.month = 8
        date8.day = 3
        date8.hour = 10
        date8.minute = 16
        let date8Date = userCalendar.date(from: date8)
        print("date8: \(date8Date)")
        
        started = date7Date
        ended = date8Date
        saveData()

        //10:46-10:55
        var date9 = DateComponents()
        date9.year = 2017
        date9.month = 8
        date9.day = 3
        date9.hour = 10
        date9.minute = 46
        let date9Date = userCalendar.date(from: date9)
        print("date9: \(date9Date)")
        
        var date10 = DateComponents()
        date10.year = 2017
        date10.month = 8
        date10.day = 3
        date10.hour = 10
        date10.minute = 55
        let date10Date = userCalendar.date(from: date10)
        print("date10: \(date10Date)")
        
        started = date9Date
        ended = date10Date
        saveData()

        print("now: \(Date())")
    }*/
}



