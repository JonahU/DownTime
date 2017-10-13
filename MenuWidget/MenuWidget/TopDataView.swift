//
//  TopDataView.swift
//  MenuWidget
//
//  Created by Jonah U on 7/13/17.
//  Copyright © 2017 Jonah U. All rights reserved.
//

import Cocoa

@IBDesignable
class TopDataView: NSView {

    @IBOutlet weak var dataButton: NSButton!
    
    @IBOutlet weak var dataTextField: NSTextField!
    @IBOutlet weak var unitsTextField: NSTextField!
    @IBOutlet weak var bottomBorder: NSView!
    
    func displayDefaultMessage(){
        DispatchQueue.main.async {
            self.updateBorder()
            
            self.unitsTextField.stringValue = "NO DATA"
            self.dataTextField.stringValue = ""
        }
    }
    
    func update(_ hours: Int, _ interval: TimeInterval){
        DispatchQueue.main.async {
            
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .short
            
            if hours == 24{
                if interval < 3600{ //1 hr
                    formatter.allowedUnits = [.minute, .second]
                }else{
                    formatter.allowedUnits = [.hour,.minute]
                }
                let formattedTotal = formatter.string(from: interval)!
                self.unitsTextField.stringValue = ("LAST 24 HRS")
                self.dataTextField.stringValue = String(formattedTotal)
            }else if hours == 168{
                formatter.allowedUnits = [.day,.hour,.minute]
                let formattedTotal = formatter.string(from: interval)!
                self.unitsTextField.stringValue = ("LAST 7 DAYS")
                self.dataTextField.stringValue = String(formattedTotal)
            }else{//not currently used
                formatter.allowedUnits = [.day,.hour,.minute]
                let formattedTotal = formatter.string(from: interval)!
                self.unitsTextField.stringValue = ("LAST \(hours)HRS")
                self.dataTextField.stringValue = String(formattedTotal)

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
    
    func updateBorder(){
        bottomBorder.wantsLayer = true
        bottomBorder.layer?.borderWidth = 1
        if isDarkMode(){
            bottomBorder.layer?.borderColor = CGColor.white
            bottomBorder.alphaValue = 0.2
        }else{
            bottomBorder.layer?.borderColor = CGColor.black
            bottomBorder.alphaValue = 0.07
        }
    }
}
