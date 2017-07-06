//
//  Date+Interval.swift
//  MenuWidget
//
//  Created by Jonah U on 6/20/17.
//  Copyright © 2017 Jonah U. All rights reserved.
//

import Foundation

extension Date {
    
    func intervalInDays(fromDate date: Date) -> Int {
        let currentCalendar = Calendar.current
        
        let start = currentCalendar.startOfDay(for: date)
        let end = currentCalendar.startOfDay(for: self)
        
        let components = currentCalendar.dateComponents([.day], from: start, to: end)
        let difference = components.value(for: .day)
        return difference!
    }
 
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
    
    func dayOfMonth() -> Int? {
        let currentCalendar = Calendar.current
        let day = currentCalendar.component(.day, from: self)
        return day
    }
}
