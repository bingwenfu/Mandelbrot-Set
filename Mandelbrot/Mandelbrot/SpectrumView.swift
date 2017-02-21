//
//  SpectrumView.swift
//
//
//  Created by Bingwen Fu on 9/3/15.
//
//

import Cocoa

class SpectrumView: NSView {
    
    var iterLimit: Int32 = 200
    var colorSet = [NSColor]()
    var colorSchme = ColorScheme()
    
    func refreshView() {
        if let cs = gen_ns_colorSet(iterLimit, &colorSchme) as? [NSColor] {
            colorSet = cs
            self.needsDisplay = true
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        guard colorSet.count != 0 else { return }
        
        let size = dirtyRect.size
        let w = size.width
        let h = size.height
        let n = CGFloat(colorSet.count)
        for y in 0..<Int(size.height) {
            let fy = CGFloat(y)
            let i = Int((fy/h)*n)
            colorSet[i].set()
            NSBezierPath.fill(CGRect(x: 0, y: CGFloat(y), width: w, height: 1))
        }
    }
}
