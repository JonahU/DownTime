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
    
    //Preferences Pane
    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var launchOptionButton: NSButtonCell!
    @IBOutlet weak var time24hrsButton: NSButtonCell!
    @IBOutlet weak var howManyValuesPopUp: NSPopUpButton!
    @IBOutlet weak var resetDataButton: NSButton!
    @IBOutlet weak var displayColorButton: NSButtonCell!
    @IBOutlet weak var ignoreValuesSlider: NSSlider!
    
    //About Pane
    @IBOutlet weak var submitFeedbackButton: NSButtonCell!
    @IBOutlet weak var submitFeedbackButtonControl: NSButton!
    @IBOutlet weak var aboutTextField: NSTextField!
    @IBOutlet weak var aboutVersionTextField: NSTextField!
    
    var delegate: PreferencesWindowDelegate?
    
    let defaults = UserDefaults.standard

    override var windowNibName: String! {
        return "PreferencesWindow"
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.isMovableByWindowBackground = true
        self.window?.titlebarAppearsTransparent = true
        self.window?.titleVisibility = .hidden
        
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        self.window?.level = Int(CGWindowLevelForKey(.maximumWindow))
        NSApp.activate(ignoringOtherApps: true)
                
        //load outlets
        loadLaunchPref()
        load24hrsPref()
        loadColorPref()
        updateResetButton()//set reset data button ACCESSIBLE/NOT ACCESSIBLE
        loadHowManyValuesPopUp()
        loadIgnoreValuesSlider()
        loadFeedbackButton()
        updateAboutPage()
    }
    
    func loadIgnoreValuesSlider(){
        let savedIgnorePref = defaults.double(forKey: "IgnorePref")
        switch savedIgnorePref {
        case 3600:
            ignoreValuesSlider.floatValue = 4
        case 900:
            ignoreValuesSlider.floatValue = 3
        case 300:
            ignoreValuesSlider.floatValue = 2
        case 60:
            ignoreValuesSlider.floatValue = 1
        case 0:
            ignoreValuesSlider.floatValue = 0
        default://shouldn't happen
            NSLog("Saved slider illegal value \(savedIgnorePref), value set to default")
            ignoreValuesSlider.floatValue = 0
        }
    }
    
    func loadFeedbackButton(){
        //make button title White
        submitFeedbackButton.attributedTitle = NSAttributedString(string: submitFeedbackButton.title, attributes: [NSForegroundColorAttributeName: NSColor.white, NSFontAttributeName: NSFont.systemFont(ofSize: 12)])
        //submitFeedbackButton.image.
        submitFeedbackButtonControl.appearance = NSAppearance.init(named: NSAppearanceNameAqua)
    }
    
    func loadColorPref(){
        displayColorButton.attributedTitle = NSAttributedString(string: displayColorButton.title, attributes: [NSForegroundColorAttributeName: NSColor.white, NSFontAttributeName: NSFont.systemFont(ofSize: 11)]) //make button title White
        
        let savedColorPref = defaults.bool(forKey: "ColorPref")
        if savedColorPref{
            displayColorButton.state = NSOnState
        }else{
            displayColorButton.state = NSOffState
        }
    }
    
    func load24hrsPref(){
        time24hrsButton.attributedTitle = NSAttributedString(string: time24hrsButton.title, attributes: [NSForegroundColorAttributeName: NSColor.white, NSFontAttributeName: NSFont.systemFont(ofSize: 11)]) //make button title White

        let saved24hrPref = defaults.bool(forKey: "24hrsPref") //returns false if no value for key
        if saved24hrPref{
            time24hrsButton.state = NSOnState;
        }
        else{  
            time24hrsButton.state = NSOffState;
        }
    }
    
    func loadLaunchPref(){
        launchOptionButton.attributedTitle = NSAttributedString(string: launchOptionButton.title, attributes: [NSForegroundColorAttributeName: NSColor.white, NSFontAttributeName: NSFont.systemFont(ofSize: 11)]) //make button title White
        
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
            howManyValuesPopUp.selectItem(at: 1)
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
        friendlyWarning(completion: {answer in
            if answer == true{
                self.delegate?.deleteAllData()
                self.resetDataButton.isEnabled = false
            }

        })
    }
    
    func friendlyWarning(completion: @escaping (Bool) -> () ) {
        let alert = NSAlert()
        alert.messageText = "Warning"
        alert.informativeText = "This change is permanent"
        alert.alertStyle = NSAlertStyle.warning
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        
        alert.beginSheetModal(for: self.window!, completionHandler: { result in
            completion(result == NSAlertFirstButtonReturn)
        })
    }
    
    func updateAboutPage(){
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            aboutVersionTextField.stringValue = "VERSION \(version)"
        }
        let savedColorPref = defaults.bool(forKey: "ColorPref")
        if isDarkMode(){
            if savedColorPref{
                aboutTextField.textColor = NSColor(calibratedHue: 0.58, saturation: 0.5, brightness: 0.9, alpha: 1)
                aboutVersionTextField.textColor = NSColor(calibratedHue: 0.58, saturation: 0.5, brightness: 0.9, alpha: 1)
            }else{
                aboutTextField.textColor = NSColor.white
                aboutVersionTextField.textColor = NSColor.white
            }
        }else{
            if savedColorPref{
                aboutTextField.textColor = NSColor(calibratedHue: 0.748, saturation: 0.8, brightness: 0.9, alpha: 1)
                aboutVersionTextField.textColor = NSColor(calibratedHue: 0.748, saturation: 0.8, brightness: 0.9, alpha: 1)
            }else{
                aboutTextField.textColor = NSColor.white
                aboutVersionTextField.textColor = NSColor.white
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
    
    @IBAction func displayColorButtonClicked(_ sender: NSButtonCell) {
        let savedColorPref = defaults.bool(forKey: "ColorPref")
        if savedColorPref{
            defaults.set(false, forKey:"ColorPref")
        }else{
            defaults.set(true, forKey:"ColorPref")
        }

    }
    
    @IBAction func ignoreValuesSliderSlid(_ sender: NSSlider) {
        let value : Float = sender.floatValue
        switch value {
        case 4:
            defaults.set(Double(3600), forKey:"IgnorePref") //1 hr
        case 3:
            defaults.set(Double(900), forKey:"IgnorePref") //15 mins
        case 2:
            defaults.set(Double(300), forKey:"IgnorePref") //5mins
        case 1:
            defaults.set(Double(60), forKey:"IgnorePref") //1 min
        case 0:
            defaults.set(Double(0), forKey:"IgnorePref")
        default://shouldn't happen
            NSLog("Slider illegal value \(value), saved value has been reset")
            defaults.set(Double(0), forKey:"IgnorePref")
        }
    }
    
    @IBAction func submitFeedbackClicked(_ sender: NSButton) {
        SendEmail.send()
    }
    
    @IBAction func doneButtonClicked(_ sender: NSButton) {
        self.close()
    }
    
    func windowWillClose(_ notification: Notification) {
        updateAboutPage()
        delegate?.preferencesDidUpdate()
    }
    
}
