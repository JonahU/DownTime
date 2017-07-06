//
//  StatusMenuController.swift
//  MenuWidget
//
//  Created by Jonah U on 6/3/17.
//  Copyright © 2017 Jonah U. All rights reserved.
//

import Cocoa
import ServiceManagement

class StatusMenuController: NSObject, PreferencesWindowDelegate {
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var usageView: UsageView!
    @IBOutlet weak var usageScrollView: UsageScrollView!
    
    var scrollViewMenuItem: NSMenuItem!
    var preferencesWindow: PreferencesWindow!
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    let defaults = UserDefaults.standard
    let usageInfo = UsageInfo()
    
    override func awakeFromNib() {
        //load menu icon + main menu
        let icon = NSImage(named: "statusIcon")
        icon?.isTemplate = true //best for darkmode
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        if defaults.bool(forKey: "HasBeenOpenedBefore") == false {
            firstTimeSetup()
        }
        
        load()
    }
    
    func load(){
        checkLoginSetting()
        observeNotifications()
        loadView()
    }
    
    func checkLoginSetting(){
        var autoStartPref = false
        let savedLaunchPref = defaults.bool(forKey: "LaunchPref")
        autoStartPref = savedLaunchPref
        
        toggleLoginAutoStart(autoStartPref)
    }
    
    func toggleLoginAutoStart(_ start:Bool){
        let launcherAppIdentifier = "com.jonahu.MenuWidgetLoginHelper" //CHANGE WITH FUNCTION CHANGE
        
        SMLoginItemSetEnabled(launcherAppIdentifier as CFString, start)
        
        // Check if the launcher app is started
        var startedAtLogin = false
        for app in NSWorkspace.shared().runningApplications {
            if app.bundleIdentifier == launcherAppIdentifier {
                startedAtLogin = true
            }
        }
        
        // If the app's started, post to the notification center to kill the launcher app
        if startedAtLogin {
            DistributedNotificationCenter.default().postNotificationName(NSNotification.Name(rawValue: "kill me"), object: Bundle.main.bundleIdentifier, userInfo: nil, options: DistributedNotificationCenter.Options.deliverImmediately)
            print("i killed the launcher app!") //COMMENT OUT AFTER TESTING
        }
        defaults.set(start, forKey: "LaunchPref")
        defaults.synchronize()

    }
    
    func firstTimeSetup(){
        //setup userdefaults
        print("First time setup...")
        defaults.set(true, forKey: "LaunchPref") //launch on login?
        defaults.set(15, forKey:"MaxDisplayPref") //max number of values to display
        defaults.set(true, forKey:"24hrsPref") //use 24hr clock?
        defaults.set(false, forKey:"SavedDataExists")
        defaults.set(0, forKey: "DataRecordsCount") //total number of recordings
        defaults.set(true, forKey: "HasBeenOpenedBefore")
    }
    
    func loadView() {        
        scrollViewMenuItem = statusMenu.item(withTitle: "ScrollView")
        scrollViewMenuItem.view = usageScrollView
        usageScrollView.documentView = usageView
        
        preferencesWindow = PreferencesWindow()
        preferencesWindow.delegate = self
        
        updateView()
    }
    
    //function communicating with UsageInfo
    func updateView(){
        var filter = defaults.integer(forKey: "MaxDisplayPref")
        if  filter == 0{//no value has been set yet forKey "MaxDisplayPref"
            filter = 15 //default value
        }
        
        usageInfo.fetchRecentData(100) {recentData in //changed filter-> 100 FIX ME
            self.usageView.update(recentData, displayLimit: filter)
        }

        if preferencesWindow.isWindowLoaded{
            preferencesWindow.updateResetButton()
        }
    }
    
    func deleteAllData(){
        usageInfo.deleteData()
        updateView()
    }
    
    //register to receive notifications for sleep + wake (+ maybe power off)
    func observeNotifications(){
        NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(sleepNotification), name: NSNotification.Name.NSWorkspaceWillSleep, object: nil)
        //NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(sleepNotification), name: NSNotification.Name.NSWorkspaceScreensDidSleep, object: nil)
        
        NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(wakeNotification), name: NSNotification.Name.NSWorkspaceDidWake, object: nil)
        //NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(wakeNotification), name: NSNotification.Name.NSWorkspaceScreensDidWake, object: nil)
        
        NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(dayChange), name: NSNotification.Name.NSCalendarDayChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateScrollFrame), name: NSNotification.Name(rawValue: "mainSizeDidCalculate"), object: nil)
    }
    
    func updateScrollFrame(aNotification : NSNotification){
        let height = defaults.integer(forKey: "ScrollHeight")
        self.usageScrollView.updateFrameHeight(height)
    }
    
    func sleepNotification(aNotification : NSNotification) {
        usageInfo.toggleDownTime(aNotification)
        NSLog("Sleep...")//FOR TESTING PURPOSES ONLY
        
    }
    
    func wakeNotification(aNotification : NSNotification) {
        usageInfo.toggleDownTime(aNotification)
        NSLog("...Wake")//FOR TESTING PURPOSES ONLY
        updateView()
    }
    
    //updates UI to display correct "today", "yesterday", "# days ago" labels
    func dayChange(aNotification : NSNotification){
        if aNotification.name == NSNotification.Name.NSCalendarDayChanged{
            updateView()
        }
    }
    
    //when Preferences window is closed
    func preferencesDidUpdate() {
        checkLoginSetting()
        updateView()
    }
    
    @IBAction func preferencesClicked(_ sender: Any) {
        preferencesWindow.showWindow(nil)
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem){
        NSWorkspace.shared().notificationCenter.removeObserver(self) //release memory
        NSApplication.shared().terminate(self)
    }
    
}

