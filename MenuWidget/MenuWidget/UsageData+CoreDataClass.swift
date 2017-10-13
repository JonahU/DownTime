//
//  UsageData+CoreDataClass.swift
//  MenuWidget
//
//  Created by Jonah U on 6/13/17.
//  Copyright © 2017 Jonah U. All rights reserved.
//

import Foundation
import CoreData

@objc(UsageData)
public class UsageData: NSManagedObject {
    func setTimeInverval(){
        timeInterval = endTime!.timeIntervalSince(startTime!)
    }
    
    func getDescription(format24hr : Bool) -> (String, String) {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.day,.hour,.minute,.second]
        let formattedTimeInterval = formatter.string(from: timeInterval)!
        
        let dateFormatter = DateFormatter()
        var formattedStartTime : String
        var formattedEndTime : String
        
        if format24hr{ //24-HR clock
            dateFormatter.dateFormat = "HH:mm"
            formattedStartTime = dateFormatter.string(from: startTime!)
            formattedEndTime = dateFormatter.string(from: endTime!)
        }else{ //12-HR clock
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            formattedStartTime = dateFormatter.string(from: startTime!)
            formattedEndTime = dateFormatter.string(from: endTime!)
        }
        return ("   \(formattedTimeInterval)", "\(formattedStartTime)-\(formattedEndTime)")
    }
    
    func compareDayDifference(date: Date) -> Int{
        //returns difference in no. of days between two UsageData objects
        let difference = date.intervalInDays(fromDate: endTime!)
        return difference
    }
    
    func howManyDaysAgo() -> Int{
        //return difference in no. of days between today's date & UsageData object
        let howManyDays = Date().intervalInDays(fromDate: endTime!)
        return howManyDays
    }
}
