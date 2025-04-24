//
//  PermissionsManager.swift
//  stack-copy
//
//  Created by Tirth Patel on 2025-04-24.
//


import Cocoa

class PermissionsManager {
    static let shared = PermissionsManager()
    
    func checkAndRequestAccessibilityPermissions() -> Bool {
        let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
        let options = [checkOptPrompt: true]
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
    
    func openAccessibilityPreferences() {
        let prefpaneURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(prefpaneURL)
    }
}