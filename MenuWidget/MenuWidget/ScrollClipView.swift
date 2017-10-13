//
//  flipClipView.swift
//  MenuWidget
//
//  Created by Jonah U on 6/23/17.
//  Copyright © 2017 Jonah U. All rights reserved.
//

import Cocoa

class ScrollClipView: NSClipView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)        
    }
    
    public final override var isFlipped: Bool{
        return true
    }

    override func viewFrameChanged(_ notification: Notification) {
        super.viewFrameChanged(notification)
        //NSLog("doc \(self.documentView?.frame.size)")
        //NSLog("doc v \(self.documentVisibleRect.size)")

    }
}
