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
                    
                    let newSubview : NSView = self.createLabel(data)
                    
                    if notFirstValue{
                        let diff = data.howManyDaysAgo() - daysAgo
                        if diff != 0 { //different day
                            
                            self.addSubview(dayContainer) //add whole day
                            self.addSubview(self.makeDateSeparator(daysAgo)) //add day label
                            
                            //reset day container
                            let sv = UsageView(width: self.frame.width)
                            dayContainer = sv
                        }
                    }
                    
                    dayContainer.addSubview(newSubview)
                    
                    if displayCounter == displayLimit{
                        //NSLog("main FRAME: \(self.frame.size), daycontainer frame: \(dayContainer.frame.size) limit: \(displayLimit)")
                        height = self.frame.height + dayContainer.frame.height
                    }
        
                    daysAgo = data.howManyDaysAgo()
                    notFirstValue = true
                }
                

                self.addSubview(dayContainer)
                self.addSubview(self.makeDateSeparator(daysAgo)) //0=today

            }else{//no data -> default view
                let newSubview: NSView = NSView(frame: NSRect(x: 0, y: 0, width: 250, height: 200))
                let newLabel : NSTextField = NSTextField(frame: NSRect(x: 50, y: 25, width: 150, height: 150))
                
                newLabel.isEditable = false
                newLabel.isBezeled = false
                newLabel.isBordered = false
                newLabel.wantsLayer = false
                newLabel.isSelectable = false
                newLabel.alignment = NSTextAlignment.center
        
                newLabel.drawsBackground = false
                newLabel.alphaValue = 0.1

                newLabel.stringValue = "😴"
                newLabel.font = NSFont(name: "Helvetica Neue Light", size: 135)
                
                newSubview.addSubview(newLabel)
                self.addSubview(newSubview)
                
            }
            var size: NSSize = self.frame.size
            size.height -= height
            //NSLog("finalsize: \(size)")
            self.postNotifcation(size)
        }
    }
    
    func createLabel(_ data : UsageData) -> NSView{
        let dataView: NSView = NSView(frame: NSRect(x: 0, y: 0, width: self.frame.width, height: 20))
        
        let leftHandSize = NSTextField(frame: NSRect(x: 0, y: 0, width: self.frame.width, height: 20))
        let rightHandSide = NSTextField(frame: NSRect(x: self.frame.width/3, y: 0, width: self.frame.width/2 + 13, height: 19))
        
        let defaults = UserDefaults.standard
        let saved24hrPref = defaults.bool(forKey: "24hrsPref")
        
        let (interval, time) = data.getDescription(format: saved24hrPref)
        
        leftHandSize.stringValue = interval //Time Interval
        
        leftHandSize.isEditable = false
        leftHandSize.isBezeled = false
        leftHandSize.isBordered = false
        leftHandSize.drawsBackground = false
        leftHandSize.wantsLayer = false
        leftHandSize.alignment = NSTextAlignment.left
        leftHandSize.font = NSFont(name: "Helvetica Neue", size: 12)
        
        rightHandSide.stringValue = time //Time info
        
        rightHandSide.isEditable = false
        rightHandSide.isBezeled = false
        rightHandSide.isBordered = false
        rightHandSide.drawsBackground = false
        rightHandSide.wantsLayer = false
        rightHandSide.alignment = NSTextAlignment.right
        rightHandSide.font = NSFont(name: "Helvetica Neue Light", size: 11)
        
        if data.timeInterval >= 7200 { //2hrs
            leftHandSize.textColor = NSColor.orange
            rightHandSide.textColor = NSColor.orange
        } else if data.timeInterval >= 1800 { //30 mins
            let customBlue = NSColor(deviceRed: 0.3, green: 0.7, blue: 1.0, alpha: 1.0)
            leftHandSize.textColor = customBlue
            rightHandSide.textColor = customBlue
        } else if data.timeInterval >= 300{ //5 mins
            let customGreen = NSColor(deviceRed: 0.1, green: 0.8, blue: 0.5, alpha: 1.0)
            leftHandSize.textColor = customGreen
            rightHandSide.textColor = customGreen
        } else{
            leftHandSize.textColor = NSColor.lightGray
            rightHandSide.textColor = NSColor.lightGray
        }
        
        dataView.addSubview(leftHandSize)
        dataView.addSubview(rightHandSide)
        return dataView
    }
    
    //MARK: -UsageView programmatic control
    
    init(width: CGFloat) {
        super.init(frame: NSMakeRect(10,0,width-20,0))
        self.wantsLayer = true
        self.layer?.cornerRadius = 5
        self.layer?.borderWidth = 1
        self.layer?.borderColor = CGColor.init(gray: 1, alpha: 0.5)
        self.layer?.backgroundColor = CGColor.init(gray: 0.5,alpha: 0.05)
    }
    
    //Default Constructor
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //setting to false so can selectively communicated with NSClipView
        //& constrain the scrollview to user selected preference
    }

    //Automatically invoked by any method that changes the view’s frame size
    override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)
    }

    
    //Overridden by subclasses to perform additional actions when subviews are added to the view
    //Auto resizes UsageView based on subclasses
     override func didAddSubview(_ subview: NSView){
        //NOTHING
     }
    
    //When UsageScrollView.setFrameSize is called, this func is automatically called (from NSView's resizeSubviews(withOldSize:) func)
    //resize informs the view that the bounds size of its superview has changed.
    //The default implementation resizes the view according to the autoresizing options specified by the autoresizingMask property.
    override func resize(withOldSuperviewSize: NSSize){
        super.resize(withOldSuperviewSize: withOldSuperviewSize)
        /*
         CURRENTLY DOES NOTHING as all autoresizing has been disabled in xib
         i.e. Does not react to superview size changes
         CAUSES SOME WEIRD janky animation WITH SCROLLING AT VERY TOP OF SCROLLVIEW 
         */
    }
    
    func makeDateSeparator(_ difference : Int) -> NSView{
        let view: NSView = NSView(frame: NSRect(x: 0, y: 0, width: self.frame.width, height: 14))
        
        let label : NSTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: self.frame.width-20, height: 14))
        label.isEditable = false
        label.isBezeled = false
        label.isBordered = false
        label.drawsBackground = false
        label.font = NSFont(name: "Helvetica Neue Light", size: 8)
        label.alignment = NSTextAlignment.right
        //label.textColor = NSColor.lightGray
        label.alphaValue = 0.5
        
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
        let label : NSTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: self.frame.width, height: 16))
        label.isEditable = false
        label.isBezeled = false
        label.isBordered = false
        label.drawsBackground = false
        label.font = NSFont.userFont(ofSize: 15)
        label.alignment = NSTextAlignment.center
        label.alphaValue = 0.1
        
        if recordingsCount == 1{
            label.stringValue = ("\(recordingsCount) DownTime record")
        }else{
            label.stringValue = ("\(recordingsCount) DownTime records")
        }
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
}
