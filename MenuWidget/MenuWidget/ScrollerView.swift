//
//  ScrollerView.swift
//  MenuWidget
//
//  Created by Jonah U on 7/10/17.
//  Copyright © 2017 Jonah U. All rights reserved.
//

import Cocoa

class ScrollerView: NSScroller {

    override func draw(_ dirtyRect: NSRect) {
        self.drawKnob()

    }
    
    override func drawKnob() {
        //DO NOTHING
    }
}
