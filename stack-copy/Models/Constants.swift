//
//  Constants.swift
//  stack-copy
//
//  Created by Tirth Patel on 2025-04-24.
//


import Foundation

struct Constants {
    static let appName = "ClipStack"
    static let defaultMaxStackSize = 10
    
    struct UserDefaults {
        static let clipboardStackKey = "clipboardStack"
        static let launchAtLoginKey = "launchAtLogin"
        static let maxStackSizeKey = "maxStackSize"
    }
    
    struct Notifications {
        static let stackFullTitle = "Stack Full"
        static let stackFullMessage = "Cannot add more items. Please delete some items from your stack."
    }
}
