//
//  AppDelegate.swift
//  stack-copy
//
//  Created by Tirth Patel on 2025-04-24.
//

import Cocoa
import SwiftUI
import KeyboardShortcuts

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    let clipboardManager = ClipboardManager.shared
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Configure app to run as a background service
        NSApp.setActivationPolicy(.accessory)
        
        // Setup menu bar item
        setupStatusBarItem()
        
        // Register keyboard shortcuts
        registerShortcuts()
        
        // Request permissions if needed
        requestAccessibilityPermissions()
    }
    
    func setupStatusBarItem() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusBarItem.button {
            button.image = NSImage(systemSymbolName: "clipboard", accessibilityDescription: "ClipStack")
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Manage Stack", action: #selector(showStackManager), keyEquivalent: "m"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Preferences", action: #selector(showPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusBarItem.menu = menu
    }
    
    @objc func showStackManager() {
        // Show stack manager window
        StackManagerWindowController.shared.showWindow(nil)
    }
    
    @objc func showPreferences() {
        // Show preferences window
        PreferencesWindowController.shared.showWindow(nil)
    }
    
    func registerShortcuts() {
        // Setup keyboard shortcuts
        KeyboardShortcuts.onKeyDown(for: .stackCopy) { [weak self] in
            self?.clipboardManager.copyToStack()
        }
        
        KeyboardShortcuts.onKeyDown(for: .stackPaste) { [weak self] in
            self?.clipboardManager.showPastePopup()
        }
        
        KeyboardShortcuts.onKeyDown(for: .stackDelete) { [weak self] in
            self?.clipboardManager.showDeletePopup()
        }
    }
    
    func requestAccessibilityPermissions() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        
        if !accessEnabled {
            // Show dialog explaining why accessibility permissions are needed
            let alert = NSAlert()
            alert.messageText = "Accessibility Permissions Required"
            alert.informativeText = "ClipStack needs accessibility permissions to detect keyboard shortcuts."
            alert.runModal()
        }
    }
}
