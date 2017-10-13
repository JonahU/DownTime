//
//  Image+Tint.swift
//  MenuWidget
//
//  Created by Jonah U on 7/30/17.
//  Copyright © 2017 Jonah U. All rights reserved.
//

import Foundation
import Cocoa

extension NSImage {
    func imageWithTintColor(tintColor: NSColor) -> NSImage {
        if self.isTemplate == false {
            return self
        }
        
        let image = self.copy() as! NSImage
        image.lockFocus()
        
        tintColor.set()
        NSRectFillUsingOperation(NSMakeRect(0, 0, image.size.width, image.size.height),.sourceAtop)
        
        image.unlockFocus()
        image.isTemplate = false
        
        return image
    }
}
