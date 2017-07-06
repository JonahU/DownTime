//
//  UsageScrollView.swift
//  MenuWidget
//
//  Created by Jonah U on 6/23/17.
//  Copyright © 2017 Jonah U. All rights reserved.
//

import Cocoa

class UsageScrollView: NSScrollView {
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.borderType = NSBorderType.noBorder
        self.hasVerticalScroller = true
        self.hasHorizontalScroller = false
        self.verticalScroller?.alphaValue = 0.0
        self.drawsBackground = false
        self.verticalScrollElasticity = .none //can lead to some weird animations when scrolling fast if enabled
        self.horizontalScrollElasticity = .none
        self.automaticallyAdjustsContentInsets = false
        self.contentInsets = NSEdgeInsetsMake(0, 0, 1, 0) //top, left, bottom, right
        
        //self.addBottomBorder() disabled for now
    }
    
    func addBottomBorder(){
        let bottomBorder = CALayer()
        bottomBorder.borderColor = CGColor.init(genericCMYKCyan: 0, magenta: 0, yellow: 1, black: 0, alpha: 0.1)
        bottomBorder.borderWidth = 1
        bottomBorder.frame = NSRect(x: 0,y: self.frame.height - 1,width: self.frame.width,height: 1)
        
        bottomBorder.autoresizingMask = [.layerMinYMargin]
        
        self.wantsLayer = true
        self.layer?.addSublayer(bottomBorder)
    }
    
    override func setFrameSize(_ newSize: NSSize) {
        DispatchQueue.main.async {
            super.setFrameSize(newSize)
        }
        NSLog("frame set: \(newSize)")
    }
    
    func updateFrameHeight(_ newHeight: Int){
        var size = self.frame.size

        size.height = CGFloat(newHeight)
        self.setFrameSize(size)
    }
    
}
