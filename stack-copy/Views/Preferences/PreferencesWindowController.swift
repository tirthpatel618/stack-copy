//
//  PreferencesWindowController.swift
//  stack-copy
//
//  Created by Tirth Patel on 2025-04-24.
//


import Cocoa
import SwiftUI

class PreferencesWindowController: NSWindowController {
    static let shared = PreferencesWindowController()
    
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Preferences"
        window.center()
        
        self.init(window: window)
        
        contentViewController = NSHostingController(rootView: PreferencesView())
    }
}