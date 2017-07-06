//
//  Preferences Window.swift
//  MenuWidget
//
//  Created by Jonah U on 6/5/17.
//  Copyright © 2017 Jonah U. All rights reserved.
//

//TODO: - Set minimum val to record (ie. ignore all DownTime values below 10 seconds etc.) + Delete CoreData (ie reset app), + eventually display customization

import Cocoa

protocol PreferencesWindowDelegate {
    func preferencesDidUpdate()
    func deleteAllData()
}

class PreferencesWindow: NSWindowController, NSWindowDelegate {
    
    @IBOutlet weak var launchOptionButton: NSButtonCell!
    @IBOutlet weak var time24hrsButton: NSButtonCell!
    @IBOutlet weak var howManyValuesPopUp: NSPopUpButton!
    @IBOutlet weak var resetDataButton: NSButton!
    
    var delegate: PreferencesWindowDelegate?
    
    let defaults = UserDefaults.standard

    override var windowNibName: String! {
        return "PreferencesWindow"
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        //load outlets
        loadLaunchPref()
        load24hrsPref()
        updateResetButton()//set reset data button ACCESSIBLE/NOT ACCESSIBLE
        loadHowManyValuesPopUp()
    }
    
    func load24hrsPref(){
        let saved24hrPref = defaults.bool(forKey: "24hrsPref") //returns false if no value for key
        if saved24hrPref{
            time24hrsButton.state = NSOnState;
        }
        else{  
            time24hrsButton.state = NSOffState;
        }
    }
    
    func loadLaunchPref(){
        //load launch at login preferences
        let savedLaunchPref = defaults.bool(forKey: "LaunchPref")
        if savedLaunchPref{ //Auto launch at login set to ON by user
            launchOptionButton.state = NSOnState;
        }
        else{ //Auto launch at login set to OFF by user
            launchOptionButton.state = NSOffState;
        }
    }
    
    func loadHowManyValuesPopUp(){
   
        let savedMaxRecent = defaults.integer(forKey: "MaxDisplayPref")
        if(howManyValuesPopUp.selectItem(withTag: savedMaxRecent)) == false{//if menu item with specified tag doesnt exist
            howManyValuesPopUp.selectItem(at: 2)
            defaults.set(howManyValuesPopUp.selectedTag(), forKey:"MaxDisplayPref")
        }

    }
    
    func updateResetButton() {
        //reset data button greyed out?
        let dataExists = defaults.bool(forKey: "SavedDataExists")
        if dataExists{
            resetDataButton.isEnabled = true
        }else{
            resetDataButton.isEnabled = false
        }
        
    }
    
    @IBAction func resetDataButtonClicked(_ sender: NSButton) {
        if friendlyWarning(){
            delegate?.deleteAllData()
            resetDataButton.isEnabled = false
        }
    }
    
    func friendlyWarning() -> Bool {
        let alert = NSAlert()
        alert.messageText = "Warning"
        alert.informativeText = "This change is permanent"
        alert.alertStyle = NSAlertStyle.warning
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == NSAlertFirstButtonReturn
    }
    
    @IBAction func howManyValuesPopUpClicked(_ sender: NSPopUpButton) {
        if sender.selectedTag() != defaults.integer(forKey: "MaxDisplayPref"){ //i.e. value changed from before
            defaults.set(sender.selectedTag(), forKey:"MaxDisplayPref")
            defaults.synchronize()
        }
    }
    
    @IBAction func launchOptionButtonClicked(_ sender: NSButtonCell) {
        let savedLaunchPref = defaults.bool(forKey: "LaunchPref")
        if savedLaunchPref{
            defaults.set(false, forKey:"LaunchPref")
        }else{
            defaults.set(true, forKey:"LaunchPref")
        }

    }
    
    @IBAction func time24hrsButtonClicked(_ sender: NSButtonCell) {
        let saved24hrPref = defaults.bool(forKey: "24hrsPref")
        if saved24hrPref{
            defaults.set(false, forKey:"24hrsPref")
        }else{
            defaults.set(true, forKey:"24hrsPref")
        }
    }
    
    @IBAction func doneButtonClicked(_ sender: NSButtonCell) {
        self.close()
    }
    
    func windowWillClose(_ notification: Notification) {
        delegate?.preferencesDidUpdate()
    }
    
}
