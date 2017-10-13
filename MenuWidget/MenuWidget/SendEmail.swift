//
//  SendEmail.swift
//  MenuWidget
//
//  Created by Jonah U on 7/21/17.
//  Copyright © 2017 Jonah U. All rights reserved.
//

import Cocoa

class SendEmail: NSObject {
    
    static func send() {
        let service = NSSharingService(named: NSSharingServiceNameComposeEmail)!
        service.recipients = ["jonahfeedback@gmail.com"]
        service.subject = "DownTime App Feedback"
        
        service.perform(withItems: [""])
    }
    
}
