//
//  StatusMenuController.swift
//  MenuWidget
//
//  Created by Jonah U on 6/3/17.
//  Copyright © 2017 Jonah U. All rights reserved.
//

import Cocoa
import ServiceManagement
import Foundation

class StatusMenuController: NSObject, PreferencesWindowDelegate {
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var usageView: UsageView!
    @IBOutlet weak var usageScrollView: UsageScrollView!
    @IBOutlet weak var prefQuitView: NSView!
    @IBOutlet weak var prefQuitViewTopBorder: NSView!
    @IBOutlet weak var quitButton: NSButton!
    @IBOutlet weak var settingsButton: NSButton!
    @IBOutlet weak var topDataView: TopDataView!
    
    var scrollViewMenuItem: NSMenuItem!
    var prefQuitMenuItem: NSMenuItem!
    var topDataViewMenuItem: NSMenuItem!
    var preferencesWindow: PreferencesWindow!
    
    var topBarClicked : Bool = false
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    let defaults = UserDefaults.standard
    let usageInfo = UsageInfo()
    
    override func awakeFromNib() {
        //load menu icon
        let icon = NSImage(named: "statusIcon")
        icon?.isTemplate = true //best for darkmode

        if let button = statusItem.button{
            button.image = icon
        } 
        statusItem.menu = statusMenu
        
        //load bottom bar
        prefQuitMenuItem = statusMenu.item(withTitle: "Pref/Quit Bar")
        prefQuitMenuItem.view = prefQuitView
        
        //load top view
        topDataViewMenuItem = statusMenu.item(withTitle: "TopDataView")
        topDataViewMenuItem.view = topDataView
        
        
        if defaults.bool(forKey: "HasBeenOpenedBefore") == false {
            firstTimeSetup()
        }
        
        //check if data was recorded on shut down/ log out
        if defaults.bool(forKey: "DidPowerOff"){
            let powerOffTime = defaults.object(forKey: "PowerOffTime") as! Date
            usageInfo.recordPowerOffTime(start: powerOffTime, end: Date())
            
            defaults.set(nil, forKey: "PowerOffTime")
            defaults.set(false, forKey: "DidPowerOff")
        }
        
        //load main view
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
        
        togglePowerOffNotifications(autoStartPref)
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
        defaults.set(false, forKey: "LaunchPref") //launch on login?
        defaults.set(15, forKey:"MaxDisplayPref") //max number of values to display
        defaults.set(Double(0), forKey:"IgnorePref")
        defaults.set(true, forKey:"24hrsPref") //use 24hr clock?
        defaults.set(true, forKey: "ColorPref") 
        defaults.set(false, forKey:"SavedDataExists")
        defaults.set(0, forKey: "DataRecordsCount") //total number of recordings
        defaults.set(false, forKey: "DidPowerOff")
        defaults.set(true, forKey: "HasBeenOpenedBefore")
    }
    
    func loadView() {
        updateBorders()
        
        scrollViewMenuItem = statusMenu.item(withTitle: "ScrollView")
        scrollViewMenuItem.view = usageScrollView
        usageScrollView.documentView = usageView
                
        preferencesWindow = PreferencesWindow()
        preferencesWindow.delegate = self
        
        updateView()
        updateTopView()
    }
    
    //function communicating with UsageInfo
    func updateView(){
        var filter = defaults.integer(forKey: "MaxDisplayPref")
        if  filter == 0{//no value has been set yet forKey "MaxDisplayPref"
            filter = 15 //default value
        }
        
        usageInfo.fetchRecentData(100) {recentData in //max display values currently 100
            self.usageView.update(recentData, displayLimit: filter)
        }

        if preferencesWindow.isWindowLoaded{
            preferencesWindow.updateResetButton()
        }
    }
    
    func deleteAllData(){
        usageInfo.deleteData()
        updateView()
        updateTopView()
    }
    
    //for PowerOff notification see togglePowerOffNotification method
    func observeNotifications(){
        //sleep + wake
        NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(sleepNotification), name: NSNotification.Name.NSWorkspaceWillSleep, object: nil)
        NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(wakeNotification), name: NSNotification.Name.NSWorkspaceDidWake, object: nil)
        
        //user session switch in + out
        NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(sleepNotification), name: NSNotification.Name.NSWorkspaceSessionDidResignActive, object: nil)
        NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(wakeNotification), name: NSNotification.Name.NSWorkspaceSessionDidBecomeActive, object: nil)
        
        //day change + time zone change
        NotificationCenter.default.addObserver(self, selector: #selector(dayChange), name: NSNotification.Name.NSSystemTimeZoneDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dayChange), name: NSNotification.Name.NSCalendarDayChanged, object: nil)
        
        //Interface Theme Change (Dark/Light mode)
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(interfaceDidChange), name: NSNotification.Name(rawValue: "AppleInterfaceThemeChangedNotification"), object: nil)
        
        //UsageView height calculated
        NotificationCenter.default.addObserver(self, selector: #selector(updateScrollFrame), name: NSNotification.Name(rawValue: "mainSizeDidCalculate"), object: nil)
        
        //menu clicked
        NotificationCenter.default.addObserver(self, selector: #selector(menuWasClicked), name: NSNotification.Name.NSMenuDidBeginTracking, object: nil)
    }
    
    //triggers when NSStatusBarButton is clicked
    func menuWasClicked(aNotification : NSNotification){
        if aNotification.name == NSNotification.Name.NSMenuDidBeginTracking{
            updateTopView()
        }
    }
    
    func updateScrollFrame(aNotification : NSNotification){
        let height = defaults.integer(forKey: "ScrollHeight")
        self.usageScrollView.updateFrameHeight(height)
    }
    
    func sleepNotification(aNotification : NSNotification) {
        if (aNotification.name == NSNotification.Name.NSWorkspaceSessionDidResignActive){
             NSWorkspace.shared().notificationCenter.removeObserver(self, name: NSNotification.Name.NSWorkspaceWillSleep, object: nil)
             NSWorkspace.shared().notificationCenter.removeObserver(self, name: NSNotification.Name.NSWorkspaceDidWake, object: nil)
        }
        
        usageInfo.toggleDownTime(aNotification)
    }
    
    func wakeNotification(aNotification : NSNotification) {
        if (aNotification.name == NSNotification.Name.NSWorkspaceSessionDidBecomeActive){
            NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(sleepNotification), name: NSNotification.Name.NSWorkspaceWillSleep, object: nil)
            NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(wakeNotification), name: NSNotification.Name.NSWorkspaceDidWake, object: nil)
        }
        
        usageInfo.toggleDownTime(aNotification)
        updateView()
        updateTopView()
    }
    
    //updates UI to display correct "today", "yesterday", "# days ago" labels + handles system time zone changes
    func dayChange(aNotification : NSNotification){
        if aNotification.name == NSNotification.Name.NSCalendarDayChanged{
            updateView()
        } else if aNotification.name == NSNotification.Name.NSSystemTimeZoneDidChange{
            updateView()
        }
    }
    
    func interfaceDidChange(aNotification : NSNotification){
        updateBorders()
        updateView()
        if preferencesWindow.isWindowLoaded{
            preferencesWindow.updateAboutPage()
        }
    }
    
    func alternateTopView(){
        let recordingsCount = defaults.integer(forKey: "DataRecordsCount")
        if recordingsCount == 0{
            self.topDataView.displayDefaultMessage()
        }else{
            if topBarClicked{
                usageInfo.fetchCalculatedData(filter: recordingsCount, hours: 24) {total in
                    self.topDataView.update(24, total)
                }
                topBarClicked = false
            } else{
                usageInfo.fetchCalculatedData(filter: recordingsCount, hours: 168) {total in
                    self.topDataView.update(168, total)
                }
                topBarClicked = true
            }
        }
    }
    
    func updateTopView(){
        let recordingsCount = defaults.integer(forKey: "DataRecordsCount")
        if recordingsCount == 0{
            self.topDataView.displayDefaultMessage()
        }else{
            if topBarClicked{
                usageInfo.fetchCalculatedData(filter: recordingsCount, hours: 168) {total in
                    self.topDataView.update(168, total)
                }
            } else{
                usageInfo.fetchCalculatedData(filter: recordingsCount, hours: 24) {total in
                    self.topDataView.update(24, total)
                }
            }
        }
    }
    
    func isDarkMode() -> Bool{
        let type = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
        if type == "Light"{
            return false
        }else{
            return true
        }
    }
    
    func updateBorders(){
        prefQuitViewTopBorder.wantsLayer = true
        prefQuitViewTopBorder.layer?.borderWidth = 1
        
        if isDarkMode(){
            prefQuitViewTopBorder.layer?.borderColor = CGColor.white
            prefQuitViewTopBorder.alphaValue = 0.2

        }else{
            prefQuitViewTopBorder.layer?.borderColor = CGColor.black
            prefQuitViewTopBorder.alphaValue = 0.07
        }
        topDataView.updateBorder()
    }
    
    func togglePowerOffNotifications(_ bool: Bool){
        if bool{
            //notification called on power off + log off
            NSWorkspace.shared().notificationCenter.removeObserver(self, name: NSNotification.Name.NSWorkspaceWillPowerOff, object: nil) //prevents duplicate observers from being added
            NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(powerNotification), name: NSNotification.Name.NSWorkspaceWillPowerOff, object: nil)
        } else{
            NSWorkspace.shared().notificationCenter.removeObserver(self, name: NSNotification.Name.NSWorkspaceWillPowerOff, object: nil)
        }
    }
    
    func powerNotification(aNotification : NSNotification){
        if aNotification.name == NSNotification.Name.NSWorkspaceWillPowerOff{
            if usageInfo.currentlyDownTime{
                defaults.set(usageInfo.started, forKey: "PowerOffTime")
                defaults.set(true, forKey: "DidPowerOff")
            }else{
                defaults.set(Date(), forKey: "PowerOffTime")
                defaults.set(true, forKey: "DidPowerOff")
            }
        }
    }
    
    @IBAction func dataButtonWasPressed(_ sender: NSButton) {
        alternateTopView()
    }
    
    //when Preferences window is closed
    func preferencesDidUpdate() {
        checkLoginSetting()
        updateView()        
    }
    
    @IBAction func quitWasClicked(_ sender: Any) {
        NSWorkspace.shared().notificationCenter.removeObserver(self) //release memory
        NSApplication.shared().terminate(self)
    }
    
    @IBAction func preferencesWasClicked(_ sender: Any) {
        statusMenu.cancelTrackingWithoutAnimation()
        preferencesWindow.showWindow(nil)
    }
}

