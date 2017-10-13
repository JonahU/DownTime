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
        NSColor.clear.set()
        NSRectFill(dirtyRect)
        self.drawKnob()
        //fixes issue with legacy/unsupported mice forcing scroller to draw

    }
    
    override func drawKnob() {
        self.knobProportion = 0.2
        super.drawKnob()
    }
}
