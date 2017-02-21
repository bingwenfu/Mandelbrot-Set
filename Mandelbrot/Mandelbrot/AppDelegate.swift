//
//  AppDelegate.swift
//  Mandelbrot
//
//  Created by Bingwen Fu on 8/26/15.
//  Copyright (c) 2015 Bingwen. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate {
    
    var allPoints = NSMutableArray()
    var dataManager = DataManager(dbPath: "/Users/Bingwen/Library/Mobile Documents/com~apple~CloudDocs/Projects/Mandelbrot Set/Mandelbrot/Mandelbrot/DB/md.db")
    var hasDeviceInfo = false
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var deviceInfoPanel: NSPanel!
    @IBOutlet weak var deviceInfoTextField: NSTextField!
    
    @IBOutlet weak var pointsTableView: NSTableView!
    @IBOutlet weak var mandelbrotGLView: MandelbrotGLView!
    @IBOutlet weak var spectrumView: SpectrumView!
    @IBOutlet weak var iterationHistView: IterationHistView!
    
    @IBOutlet weak var iterationTextField: NSTextField!
    @IBOutlet weak var leftXTextField: NSTextField!
    @IBOutlet weak var leftYTextField: NSTextField!
    @IBOutlet weak var BottomXTextField: NSTextField!
    @IBOutlet weak var bottomYTextField: NSTextField!
    @IBOutlet weak var zoomRatioTextField: NSTextField!
    @IBOutlet weak var widthTextField: NSTextField!
    
    @IBOutlet weak var colorwell1: NSColorWell!
    @IBOutlet weak var colorwell2: NSColorWell!
    @IBOutlet weak var colorwell3: NSColorWell!
    @IBOutlet weak var colorwell4: NSColorWell!
    
    @IBOutlet weak var slider1: NSSlider!
    @IBOutlet weak var slider2: NSSlider!
    @IBOutlet weak var slider3: NSSlider!
    @IBOutlet weak var slider4: NSSlider!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        NotificationCenter.default.addObserver(self, selector:#selector(AppDelegate.updateControlPanel), name: NSNotification.Name(rawValue: "mandelbrotGLViewFinishedDrawing"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.tableViewSelectionDidChange(_:)), name: NSNotification.Name.NSTableViewSelectionDidChange, object: nil)
        
        allPoints = (dataManager?.fetchAllPoints())!
        pointsTableView.dataSource = self
        pointsTableView.delegate = self
    }
    
    func colorFromColorWell(_ cw: NSColorWell) -> Color {
        var c = Color()
        c.r = Float(cw.color.redComponent)
        c.g = Float(cw.color.greenComponent)
        c.b = Float(cw.color.blueComponent)
        return c
    }
    
    func updateControlPanel() {
        let p = mandelbrotGLView.p
        leftXTextField.stringValue = String(stringInterpolationSegment: p.x1)
        BottomXTextField.stringValue = String(stringInterpolationSegment: p.x2)
        leftYTextField.stringValue = String(stringInterpolationSegment: p.y1)
        bottomYTextField.stringValue = String(stringInterpolationSegment: p.y2)
        iterationTextField.stringValue = String(mandelbrotGLView.iterLimit)
        zoomRatioTextField.stringValue = String(stringInterpolationSegment: mandelbrotGLView.zoomRatio)
        widthTextField.stringValue = String(stringInterpolationSegment: (p.x2-p.x1))
        
        let cs = mandelbrotGLView.colorScheme
        colorwell1.color = cColor2NSColor(cs.color1)
        colorwell2.color = cColor2NSColor(cs.color2)
        colorwell3.color = cColor2NSColor(cs.color3)
        colorwell4.color = cColor2NSColor(cs.color4)
        
        slider1.doubleValue = Double(mandelbrotGLView.colorScheme.colorLine1*100)
        slider2.doubleValue = Double(mandelbrotGLView.colorScheme.colorLine2*100)
        
        let upper: Float = 30.0
        let lower: Float = 1.0
        var a = mandelbrotGLView.colorScheme.a
        a = (a - lower)/(upper-lower)
        a = a*100
        slider3.doubleValue = Double(a)
        
        spectrumView.iterLimit = mandelbrotGLView.iterLimit
        spectrumView.colorSchme = mandelbrotGLView.colorScheme
        spectrumView.refreshView()
        
        if mandelbrotGLView.displayType == MANDELBROT_SET {
            iterationHistView.colorSchme = mandelbrotGLView.colorScheme
            iterationHistView.histArr = mandelbrotGLView.histArr
            iterationHistView.nBins = Int(mandelbrotGLView.histBins)
            iterationHistView.iterLimit = mandelbrotGLView.iterLimit
            iterationHistView.refreshView()
        }
        
        if hasDeviceInfo == false {
            updateDeviceInfo()
            hasDeviceInfo = true
        }
    }
    
    func updateDeviceInfo() {
        

    }
    
    @IBAction func colorweel1Changed(_ sender: NSColorWell) {
        mandelbrotGLView.colorScheme.color1 = colorFromColorWell(sender)
        mandelbrotGLView.updateColor()
    }
    
    @IBAction func colorwell2Changed(_ sender: NSColorWell) {
        mandelbrotGLView.colorScheme.color2 = colorFromColorWell(sender)
        mandelbrotGLView.updateColor()
    }
    
    @IBAction func colorwell3Changed(_ sender: NSColorWell) {
        mandelbrotGLView.colorScheme.color3 = colorFromColorWell(sender)
        mandelbrotGLView.updateColor()
    }
    
    @IBAction func colorwell4Changed(_ sender: NSColorWell) {
        mandelbrotGLView.colorScheme.color4 = colorFromColorWell(sender)
        mandelbrotGLView.updateColor()
    }
    
    @IBAction func slider1Changes(_ sender: NSSlider) {
        mandelbrotGLView.colorScheme.colorLine1 = Float(sender.doubleValue*0.01)
        mandelbrotGLView.updateColor()
    }
    
    @IBAction func slider2Changes(_ sender: NSSlider) {
        mandelbrotGLView.colorScheme.colorLine2 = Float(sender.doubleValue*0.01)
        mandelbrotGLView.updateColor()
    }
    
    @IBAction func slider3Changes(_ sender: NSSlider) {
        let upper: Float = 30.0
        let lower: Float = 1.0
        var a: Float = Float(sender.doubleValue)
        a = (a/100.0)*(upper-lower) + lower
        
        mandelbrotGLView.colorScheme.a = a
        mandelbrotGLView.updateColor()
    }
    
    @IBAction func slider4Changes(_ sender: NSSlider) {
        
    }
    
    @IBAction func clipColorChecked(_ sender: NSButton) {
        mandelbrotGLView.clipColor = (sender.state == 1)
        mandelbrotGLView.updateColor()
    }
    
    @IBAction func zoomOutButtomClick(_ sender: AnyObject) {
        mandelbrotGLView.zoomOut()
    }
    
    @IBAction func zoomRatioTextFieldEntered(_ sender: AnyObject) {
        mandelbrotGLView.zoomRatio = zoomRatioTextField.doubleValue
    }
    
    @IBAction func iterationTextFieldEntered(_ sender: NSTextField) {
        if sender.integerValue <= 0 {
            return
        }
        mandelbrotGLView.iterLimit = Int32(sender.integerValue)
        mandelbrotGLView.redrawMandelbrot(withCalculation: true)
    }
    
    @IBAction func saveImageButtomClick(_ sender: AnyObject) {
        mandelbrotGLView.writeCurrentFrameAsImageToDisk()
    }
    
    @IBAction func savePointsClick(_ sender: AnyObject) {
        dataManager?.saveParameters(toDB: mandelbrotGLView.p, colorScheme: mandelbrotGLView.colorScheme, iterLimit:mandelbrotGLView.iterLimit)
    }
    
    @IBAction func fractalTypeSelected(_ sender: NSPopUpButton) {
        if let str = sender.titleOfSelectedItem {
            if str == "Mandelbrot Set" {
                mandelbrotGLView.displayType = MANDELBROT_SET
            } else if str == "Julia Set" {
                mandelbrotGLView.displayType = JULIA_SET
            } else {
                print("Unknown selection: \(str) [\( #function)]")
            }
        }
    }
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return allPoints.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let v = tableView.make(withIdentifier: "PointsCell", owner: self) as? NSTableCellView {
            if let parameters = allPoints[row] as? MandelbrotParameters {
                if tableColumn?.identifier == "leftColumn" {
                    v.textField!.stringValue = String(parameters.id)
                } else {
                    v.textField!.stringValue = String(parameters.iterLimit)
                }
            }
            return v;
        }
        return nil;
    }
    
    @objc(tableViewSelectionDidChange:) func tableViewSelectionDidChange(_ notification: Notification) {
        let row = pointsTableView.selectedRow
        if let parameters = allPoints[row] as? MandelbrotParameters {
            mandelbrotGLView.iterLimit = parameters.iterLimit
            mandelbrotGLView.colorScheme = parameters.colorScheme
            mandelbrotGLView.p = parameters.plane
            mandelbrotGLView.redrawMandelbrot(withCalculation: true)
        }
    }
}

