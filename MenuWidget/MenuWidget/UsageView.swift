//
//  ContentView.swift
//  MenuWidget
//
//  Created by Jonah U on 6/5/17.
//  Copyright © 2017 Jonah U. All rights reserved.
//

import Cocoa

let DEFAULT_TEXT = "No DownTime data to display"
let DEFAULT_IGNORE_VAL: TimeInterval = 0 //do not update UI with values below default, 0 = display everything

@IBDesignable
class UsageView: NSView {
    
    func update(_ recentData : [UsageData], displayLimit: Int){
        
        //do UI updates on main thread
        DispatchQueue.main.async {
            var height : CGFloat = 0

            self.removeAll()
            if recentData.isEmpty == false{
                
                var notFirstValue = false
                var daysAgo: Int = 0
                var displayCounter = recentData.count
                
                var dayContainer = UsageView(width: self.frame.width)
                
                let displayDataCount = self.makeRecordCountLabel()
                self.addSubview(displayDataCount)
                
                for i in 0..<recentData.count{
                    let data = recentData[recentData.count - 1 - i]
                    displayCounter -= 1
                    
                    let newSubview : NSView = self.createDataLabel(data)
                    
                    if notFirstValue{
                        let diff = data.howManyDaysAgo() - daysAgo
                        if diff != 0 { //different day
                            
                            dayContainer.addSubview(self.makeDateSeparator(daysAgo))
                            self.addSubview(dayContainer)
                            self.addPadding(height: 5)
                            
                            //reset day container
                            let sv = UsageView(width: self.frame.width)
                            dayContainer = sv
                        }
                    }
                    
                    dayContainer.addSubview(newSubview)
                    
                    if displayCounter == displayLimit{
                        height = self.frame.height + dayContainer.frame.height
                    }
        
                    daysAgo = data.howManyDaysAgo()
                    notFirstValue = true
                }
                
                dayContainer.addSubview(self.makeDateSeparator(daysAgo))
                self.addSubview(dayContainer)
                self.addPadding(height: 7)
                
            }else{//no data -> default view
                let newSubview: NSView = NSView(frame: NSRect(x: 0, y: 0, width: 250, height: 200))
                let newImageView : NSImageView = NSImageView(frame: NSRect(x: 50, y: 25, width: 150, height: 150))
                
                newImageView.image = NSImage(named: "noDataImage")
                newImageView.wantsLayer = false
                newImageView.alphaValue = 0.1

                
                newSubview.addSubview(newImageView)
                self.addSubview(newSubview)
                
            }
            var size: NSSize = self.frame.size
            size.height -= height
            self.postNotifcation(size)
        }
    }
    
    func createDataLabel(_ data : UsageData) -> NSView{
        let dataView: NSView = NSView(frame: NSRect(x: 0, y: 0, width: self.frame.width, height: 20))
        
        let leftHandSide = NSTextField(frame: NSRect(x: 0, y: 0, width: self.frame.width, height: 21.5))
        let rightHandSide = NSTextField(frame: NSRect(x: self.frame.width/3, y: 0, width: self.frame.width/2 + 13, height: 17.5))
        
        let defaults = UserDefaults.standard
        let saved24hrPref = defaults.bool(forKey: "24hrsPref")
        
        let (interval, time) = data.getDescription(format24hr: saved24hrPref)
        leftHandSide.stringValue = interval //Time Interval
        rightHandSide.stringValue = time //Time info
        
        leftHandSide.isEditable = false
        leftHandSide.isBezeled = false
        leftHandSide.isBordered = false
        leftHandSide.drawsBackground = false
        leftHandSide.wantsLayer = false
        leftHandSide.alignment = NSTextAlignment.left
        rightHandSide.isEditable = false
        rightHandSide.isBezeled = false
        rightHandSide.isBordered = false
        rightHandSide.drawsBackground = false
        rightHandSide.wantsLayer = false
        rightHandSide.alignment = NSTextAlignment.right
        
        if data.isPowerOffData{//power off, restart, log off, user switch etc.
            leftHandSide.font = NSFont(name: "Helvetica Neue Medium Italic", size: 12)
            rightHandSide.font = NSFont(name: "Helvetica Neue", size: 11)
            
            //adds arrow icon
            let indicator: NSImage
            let indicatorView = NSImageView.init(frame: NSRect(x: 5, y: 0, width: 5, height: 19))
            
            if isDarkMode(){
                let tintColor = NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.6)
                indicator = (NSImage(named: "NSRightFacingTriangleTemplate")?.imageWithTintColor(tintColor: tintColor))!
            }else{
                indicator = NSImage(named: "NSRightFacingTriangleTemplate")!
                indicatorView.alphaValue = 0.8
            }
            indicatorView.image = indicator
            indicatorView.imageAlignment = NSImageAlignment.alignLeft
            dataView.addSubview(indicatorView)
        }else{//regular data
            leftHandSide.font = NSFont(name: "Helvetica Neue Medium", size: 12)
            rightHandSide.font = NSFont(name: "Helvetica Neue", size: 11)
        }
        
        let savedColorPref = defaults.bool(forKey: "ColorPref")
        let darkMode = isDarkMode()
        
        if savedColorPref{//i.e. DISPLAY COLOR
            if data.timeInterval >= 86400 { //1 day
                if darkMode{
                    let customMagenta = NSColor(calibratedHue: 0.8, saturation: 0.95, brightness: 1, alpha: 1)
                    leftHandSide.textColor = customMagenta
                    rightHandSide.textColor = customMagenta
                }else{
                    let customDarkBlue = NSColor(calibratedHue: 0.6, saturation: 1, brightness: 1, alpha: 1)
                    leftHandSide.textColor = customDarkBlue
                    rightHandSide.textColor = customDarkBlue
                }
            } else if data.timeInterval >= 14400 { //4 hrs
                if darkMode{
                    let customBlue = NSColor(calibratedHue: 0.605, saturation: 0.95, brightness: 1, alpha: 1)
                    leftHandSide.textColor = customBlue
                    rightHandSide.textColor = customBlue
                }else{
                    let customPurple = NSColor(calibratedHue: 0.738, saturation: 1, brightness: 0.9, alpha: 0.9)
                    leftHandSide.textColor = customPurple
                    rightHandSide.textColor = customPurple
                }
            } else if data.timeInterval >= 300{ //5 mins
                if darkMode{
                    let customLightBlue = NSColor(calibratedHue: 0.58, saturation: 0.5, brightness: 0.9, alpha: 1)
                    leftHandSide.textColor = customLightBlue
                    rightHandSide.textColor = customLightBlue
                }else{
                    let customLightPurple = NSColor(calibratedHue: 0.748, saturation: 0.8, brightness: 0.9, alpha: 0.7)
                    leftHandSide.textColor = customLightPurple
                    rightHandSide.textColor = customLightPurple
                }
            } else{ //less than 5 mins
                if darkMode{
                    leftHandSide.textColor = NSColor.controlShadowColor
                    rightHandSide.textColor = NSColor.controlShadowColor
                }else{
                    leftHandSide.textColor = NSColor.init(calibratedWhite: 0.5, alpha: 0.8)
                    rightHandSide.textColor = NSColor.init(calibratedWhite: 0.5, alpha: 0.8)
                }
            }
            
        }else{//i.e. GRAYSCALE
            if data.timeInterval >= 14400 { //4hrs
                if darkMode{
                    leftHandSide.textColor = NSColor.init(calibratedWhite: 0.9, alpha: 1)
                    rightHandSide.textColor = NSColor.init(calibratedWhite: 0.9, alpha: 1)
                }else{
                    leftHandSide.textColor = NSColor.init(calibratedWhite: 0, alpha: 0.6)
                    rightHandSide.textColor = NSColor.init(calibratedWhite: 0, alpha: 0.6)
                }
            }else{
                if darkMode{
                    leftHandSide.textColor = NSColor.lightGray
                    rightHandSide.textColor = NSColor.lightGray
                }else{
                    leftHandSide.textColor = NSColor.init(calibratedWhite: 0.5, alpha: 1)
                    rightHandSide.textColor = NSColor.init(calibratedWhite: 0.5, alpha: 1)
                }
            }
        }
        
        dataView.addSubview(leftHandSide)
        dataView.addSubview(rightHandSide)
        dataView.wantsLayer = false
        return dataView
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(width: CGFloat) {
        super.init(frame: NSMakeRect(10,0,width-20,0))
        self.wantsLayer = true
        self.layer?.cornerRadius = 4
        self.layer?.borderWidth = 1
        self.canDrawSubviewsIntoLayer = true
        
        if isDarkMode(){
            self.layer?.borderColor = CGColor.init(gray: 1, alpha: 0.5)
            self.layer?.backgroundColor = CGColor.clear
        }else{
            self.layer?.borderColor = CGColor.clear
            self.layer?.backgroundColor = CGColor.init(gray: 1,alpha: 0.5)
        }
    }
    
    init(label: NSView, content: UsageView){
        super.init(frame: NSMakeRect(10,0,content.frame.width,0))
        self.wantsLayer = true
        self.layer?.cornerRadius = 4
        self.layer?.borderWidth = 1
        self.canDrawSubviewsIntoLayer = true
        
        if isDarkMode(){
            self.layer?.borderColor = CGColor.clear
            self.layer?.backgroundColor = CGColor.clear
        }else{
            self.layer?.borderColor = CGColor.clear
            self.layer?.backgroundColor = CGColor.clear
        }
        
        content.addSubview(label)
        self.addSubview(content)
    }

    
    //Overridden by subclasses to perform additional actions when subviews are added to the view
    //Auto resizes UsageView based on subclasses
     override func didAddSubview(_ subview: NSView){
        //NOTHING
     }
    
    func makeDateSeparator(_ difference : Int) -> NSView{
        let view: NSView = NSView(frame: NSRect(x: 0, y: 0, width: self.frame.width-20, height: 14))
        view.wantsLayer = true
        
        let label : NSTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: self.frame.width-20, height: 14))

        label.isEditable = false
        label.isBezeled = false
        label.isBordered = false
        label.drawsBackground = false
        label.font = NSFont(name: "Helvetica Neue", size: 8)
        label.alignment = NSTextAlignment.center
        
        if isDarkMode(){
            let bottomBorder = CALayer()
            bottomBorder.borderWidth = 1
            bottomBorder.frame = NSRect(x: 1,y: 0,width: view.frame.width-2,height: 1)
            bottomBorder.borderColor = CGColor.init(gray: 1, alpha: 0.05)
            bottomBorder.autoresizingMask = [.layerMinYMargin]
            view.layer?.addSublayer(bottomBorder)
            
            label.alphaValue = 0.8
            label.textColor = NSColor.init(deviceWhite: 1, alpha: 0.7)
        }else{
            view.layer?.backgroundColor = CGColor.init(gray: 0.6, alpha: 0.05)
            label.alphaValue = 0.9
            label.textColor = NSColor.init(deviceWhite: 0, alpha: 0.5)
        }
        
        if difference == 0{
            label.stringValue = ("Today")
        }else if difference == 1{
            label.stringValue = ("Yesterday")
        }else{
            label.stringValue = ("\(difference) days ago")
        }
        
        view.addSubview(label)
        return view
    }
    
    func makeRecordCountLabel() -> NSView{
        let defaults = UserDefaults.standard
        let recordingsCount = defaults.integer(forKey: "DataRecordsCount")
        
        let view: NSView = NSView(frame: NSRect(x: 0, y: 0, width: self.frame.width, height: 22))
        let label : NSTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: self.frame.width, height: 17))
        label.isEditable = false
        label.isBezeled = false
        label.isBordered = false
        label.drawsBackground = false
        label.font = NSFont.userFont(ofSize: 15)
        label.alignment = NSTextAlignment.center
        label.textColor = NSColor.quaternaryLabelColor
        
        if recordingsCount == 1{
            label.stringValue = ("\(recordingsCount) DownTime record")
        }else{
            label.stringValue = ("\(recordingsCount) DownTime records")
        }
        view.addSubview(label)

        return view
    }
    
    func addPadding(height : CGFloat){
        let padding: NSView = NSView(frame: NSRect(x: 0, y: 0, width: self.frame.width, height: height))
        self.addSubview(padding)
    }
    
    //not used
    func addSeparator(){
        let separator = NSView(frame: NSRect(x:self.frame.origin.x, y: 0, width: self.frame.width, height: 1))
        let line = NSView(frame: NSRect(x:25, y: 0, width: self.frame.width - 50, height: 1))
        
        line.wantsLayer = true
        line.layer?.borderWidth = 1
        line.layer?.borderColor = CGColor.init(gray: 0, alpha: 0.5)
        
        separator.addSubview(line)
        self.addSubview(separator)
    }
    
    //Currently not used, feature encorporated into TopDataView & UsageInfo instead
    func makeTotalDownTimeLabel(hours: Int, dataArray: [UsageData]) -> NSView{
        let now = Date()
        let interval : TimeInterval = TimeInterval(-hours * 3600) //3600 seconds in 1 hour
        let earlierDate = now.addingTimeInterval(interval)
        var total : TimeInterval = 0
        
        for data in dataArray{
            if (data.startTime?.timeIntervalSinceNow)! <= interval{
                if data.endTime! > earlierDate{
                    let split : TimeInterval = data.endTime!.timeIntervalSince(earlierDate)
                    total += split
                }
                break
            }
            total += data.timeInterval
        }
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour,.minute]
        let formattedTotal = formatter.string(from: total)!
        //NSLog("total time: \(formattedTotal)")
        
        let view: NSView = NSView(frame: NSRect(x: 0, y: 0, width: self.frame.width, height: 23))
        let label : NSTextField = NSTextField(frame: NSRect(x: 40, y: 0, width: self.frame.width - 80, height: 19))
        label.isEditable = false
        label.isBezeled = false
        label.isBordered = false
        label.drawsBackground = false
        label.font = NSFont(name: "Helvetica Neue Bold", size: 12.5)
        label.alignment = NSTextAlignment.center
        label.alphaValue = 0.5
        
        label.stringValue = ("Last \(hours)hrs: \(formattedTotal)")
        view.addSubview(label)
        
        return view
    }
    
    func increaseFrameSize(_ subview: NSView) {
        var yPos: CGFloat = 0 //y Coordinate of main view where subview will be inserted
        for view in subviews{
            yPos += view.frame.size.height
        }

        var f = self.frame
        f.size.height = yPos + subview.frame.size.height 
        subview.frame.origin.y = yPos
        self.frame = f
    }
    
    func getHeight(){
        var yPos: CGFloat = 0 //y Coordinate of main view where subview will be inserted
        for view in subviews{
            yPos += view.frame.size.height
        }
    }
    
    //main controller catches notification and updates the scrollview's height
    func postNotifcation(_ size: NSSize){
        let defaults = UserDefaults.standard
        let height : Int = Int(size.height)
        //NSLog("height notification \(size.height)")
        defaults.set(height, forKey: "ScrollHeight")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "mainSizeDidCalculate"), object: nil)
    }
    
    override func addSubview(_ view: NSView) {
        self.increaseFrameSize(view)
        super.addSubview(view)
    }
    
    func removeAll() {
        for view in subviews {
            view.removeFromSuperview()
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
}
