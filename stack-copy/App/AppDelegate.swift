//
//  AppDelegate.swift
//  stack-copy
//
//  Created by Tirth Patel on 2025-04-24.
//

import Cocoa
import SwiftUI
import KeyboardShortcuts
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    var statusBarItem: NSStatusItem!
    let clipboardManager = ClipboardManager.shared
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Configure app to run as a background service
        NSApp.setActivationPolicy(.accessory)
        
        // Setup menu bar item
        setupStatusBarItem()
        
        // Register keyboard shortcuts
        registerShortcuts()
        
        // Request permissions
        requestAccessibilityPermissions()
        
        // Setup notification delegate and request permission
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Failed to request notification permission: \(error)")
            }
        }
    }
    
    func setupStatusBarItem() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusBarItem.button {
            button.image = NSImage(systemSymbolName: "clipboard", accessibilityDescription: "stack-copy")
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
            let alert = NSAlert()
            alert.messageText = "Accessibility Permissions Required"
            alert.informativeText = "stack-copy needs accessibility permissions to detect keyboard shortcuts."
            alert.runModal()
        }
    }
    
    // Optional: Handle notification presentation
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Display alert even when app is in foreground
        completionHandler([.banner, .sound])
    }
}
