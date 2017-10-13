//
//  UsageScrollView.swift
//  MenuWidget
//
//  Created by Jonah U on 6/23/17.
//  Copyright © 2017 Jonah U. All rights reserved.
//

import Cocoa
import QuartzCore

class UsageScrollView: NSScrollView {
    
//    let topBorder : CALayer
//    let bottomBorder : CALayer
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    required init?(coder aDecoder: NSCoder) {
//        self.topBorder = CALayer()
//        self.bottomBorder = CALayer()
        super.init(coder: aDecoder)
        
        self.wantsLayer = false //smoother scrolling?, lower memory usage on app use (~30%), slightly higher standby memory usage (~10%)
        self.drawsBackground = false
        self.borderType = NSBorderType.noBorder
        
        self.hasVerticalScroller = true
        self.verticalScroller?.alphaValue = 0.0
        self.hasHorizontalScroller = false
        
        self.verticalScrollElasticity = .none //can lead to some weird animations when scrolling fast if enabled
        self.horizontalScrollElasticity = .none
        self.automaticallyAdjustsContentInsets = false
        self.contentInsets = NSEdgeInsetsMake(0, 0, 0, 0) //top, left, bottom, right
    }
    
    override func setFrameSize(_ newSize: NSSize) {
        DispatchQueue.main.async {
            super.setFrameSize(newSize)
        }
        //NSLog("frame set: \(newSize)")
    }
    
    func updateFrameHeight(_ newHeight: Int){
        var size = self.frame.size

        size.height = CGFloat(newHeight)
        self.setFrameSize(size)
    }
    
/*   //not used
     func scrollViewDidScroll(_ notification: NSNotification){
        let y = self.contentView.bounds.minY
        if(y >= self.contentView.documentRect.minY + 2.0){
            topBorder.isHidden = false
        }else{
            topBorder.isHidden = true
        }        
    }
    
    //not used
    func addBottomBorder(){
        bottomBorder.borderWidth = 1
        bottomBorder.frame = NSRect(x: 0,y: self.frame.height - 1,width: self.frame.width,height: 1)
        
        bottomBorder.autoresizingMask = [.layerMinYMargin]
        
        self.layer?.addSublayer(bottomBorder)
    }
    
    //not used
    func addTopBorder(){
        NotificationCenter.default.addObserver(self, selector: #selector (scrollViewDidScroll), name: NSNotification.Name.NSViewBoundsDidChange, object: self.contentView)
        topBorder.isHidden = true
        
        topBorder.borderWidth = 1
        topBorder.frame = NSRect(x: 0,y: 0,width: self.frame.width,height: 1)
        
        topBorder.autoresizingMask = [.layerMaxYMargin]
        
        self.layer?.addSublayer(topBorder)
        
    }
    
    //not used
    func updateBorderColors(){
        if isDarkMode(){
            topBorder.borderColor = CGColor.init(gray: 0.9, alpha: 0.1)
            bottomBorder.borderColor = CGColor.init(gray: 0.9, alpha: 0.1)
        }else{
            topBorder.borderColor = CGColor.init(gray: 0.1, alpha: 0.1)
            bottomBorder.borderColor = CGColor.init(gray: 0.1, alpha: 0.1)
        }
    }*/
    
    func isDarkMode() -> Bool{
        let type = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
        if type == "Light"{
            return false
        }else{
            return true
        }
    }
    
    override func tile() {
        super.tile()
        self.contentView.setFrameSize(self.bounds.size)
    }
    
    //not currently used
    func addTopGradient(){
        let gradient = CAGradientLayer()
        gradient.frame = NSRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        gradient.colors = [NSColor.clear.cgColor, NSColor.white.cgColor] //[bottomColor, topColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 0.03)
        gradient.autoresizingMask = [.layerHeightSizable]
        self.layer?.mask = gradient
    }
    
}
