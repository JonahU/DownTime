//
//  AppDelegate.swift
//  MenuWidgetLoginHelper
//
//  Created by Jonah U on 6/3/17.
//  Copyright © 2017 Jonah U. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let mainAppIdentifier = "com.jonahu.MenuWidget" //CHANGE WITH FUNCTION CHANGE
        let running = NSWorkspace.shared().runningApplications
        var alreadyRunning = false
        
        for app in running {
            if app.bundleIdentifier == mainAppIdentifier {
                alreadyRunning = true
                break
            }
        }
        
        if !alreadyRunning {
            // Register for the notification killme
            DistributedNotificationCenter.default().addObserver(self, selector: #selector(self.terminate), name: NSNotification.Name(rawValue: "kill me"), object: mainAppIdentifier)
            
            // Get the path of the current app and nativate through them to find the Main Application
            let path = Bundle.main.bundlePath as NSString
            var components = path.pathComponents
            components.removeLast(3)
            components.append("MacOS")
            components.append("MenuWidget") //MAIN APP NAME, CHANGE WITH FUNCTION CHANGE
            
            let newPath = NSString.path(withComponents: components)
            
            //Launch the Main application
            NSWorkspace.shared().launchApplication(newPath)
        }
        else {
            //Main application is already running
            self.terminate()
        }
    }
    
    func terminate() {
        print("Terminating helper application") //COMMENT OUT AFTER TESTING
        NSApp.terminate(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

