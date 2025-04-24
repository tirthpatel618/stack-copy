//
//  StackManagerWindowController.swift
//  stack-copy
//
//  Created by Tirth Patel on 2025-04-24.
//


import Cocoa
import SwiftUI

class StackManagerWindowController: NSWindowController {
    static let shared = StackManagerWindowController()
    
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Manage Clipboard Stack"
        window.center()
        
        self.init(window: window)
        
        contentViewController = NSHostingController(
            rootView: StackManagerView()
                .environmentObject(ClipboardManager.shared)
        )
    }
}