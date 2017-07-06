//
//  UsageData+CoreDataProperties.swift
//  MenuWidget
//
//  Created by Jonah U on 6/13/17.
//  Copyright © 2017 Jonah U. All rights reserved.
//

import Foundation
import CoreData


extension UsageData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UsageData> {
        return NSFetchRequest<UsageData>(entityName: "UsageData");
    }

    @NSManaged public var endTime: Date?
    @NSManaged public var startTime: Date?
    @NSManaged public var timeInterval: TimeInterval

}
