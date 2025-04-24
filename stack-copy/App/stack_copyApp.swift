//
//  stack_copyApp.swift
//  stack-copy
//
//  Created by Tirth Patel on 2025-04-23.
//

import SwiftUI

@main
struct ClipStackApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
