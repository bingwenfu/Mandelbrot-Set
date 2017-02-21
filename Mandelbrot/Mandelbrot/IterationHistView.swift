//
//  IterationHistView.swift
//  Mandelbrot
//
//  Created by Bingwen Fu on 10/21/15.
//  Copyright © 2015 Bingwen. All rights reserved.
//

import Cocoa

class IterationHistView: NSView {
    
    var nBins = 100;
    var histArr = NSMutableArray()
    var iterLimit: Int32 = 200
    
    var colorSchme = ColorScheme()
    var colorSet = [NSColor]()
    
    override func awakeFromNib() {
        layer?.borderColor = NSColor.black.cgColor
        layer?.borderWidth = 2.0
    }
    
    func refreshView() {
        if let cs = gen_ns_colorSet(iterLimit, &colorSchme) as? [NSColor] {
            colorSet = cs
            self.needsDisplay = true
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        guard histArr.count != 0 else { return }
        guard colorSet.count != 0 else { return }
        
        let size = dirtyRect.size
        let w = size.width
        let h = size.height
        
        var max = 0
        for i in histArr {
            if let v = (i as AnyObject).integerValue {
                if v > max {
                    max = v
                }
            }
        }
        
        for i in 1..<nBins {
            let bx = (CGFloat(i)/CGFloat(nBins))*w
            if let niter = (histArr[i] as AnyObject).integerValue {
                let bh = (CGFloat(niter)/CGFloat(max))*h
                var ci = (CGFloat(i+1)/CGFloat(nBins))*CGFloat(iterLimit)
                ci = ci - 1.0
                if ci < 0 {
                    ci = 0
                }
                colorSet[Int(ci)].set()
                NSBezierPath.fill(CGRect(x: bx-10, y: 0, width: w/CGFloat(nBins), height: bh))
            }
        }
    }
}
