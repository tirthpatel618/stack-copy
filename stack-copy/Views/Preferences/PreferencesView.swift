//
//  PreferencesView.swift
//  stack-copy
//
//  Created by Tirth Patel on 2025-04-24.
//


import SwiftUI
import KeyboardShortcuts
import ServiceManagement

struct PreferencesView: View {
    @AppStorage(Constants.UserDefaults.launchAtLoginKey) private var launchAtLogin = false
    
    var body: some View {
        TabView {
            GeneralPreferencesView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            
            ShortcutPreferencesView()
                .tabItem {
                    Label("Shortcuts", systemImage: "command")
                }
        }
        .padding()
        .frame(width: 400, height: 300)
    }
}

struct GeneralPreferencesView: View {
    @AppStorage(Constants.UserDefaults.launchAtLoginKey) private var launchAtLogin = false
    @AppStorage(Constants.UserDefaults.maxStackSizeKey) private var maxStackSize = Constants.defaultMaxStackSize
    
    var body: some View {
        Form {
            Toggle("Launch at login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { oldValue, newValue in
                    setLaunchAtLogin(newValue)
                }
            
            Stepper("Maximum stack size: \(maxStackSize)", value: $maxStackSize, in: 5...20)
        }
        .padding()
    }
    
    func setLaunchAtLogin(_ enabled: Bool) {
        // Use SMAppService for macOS 13+ or SMLoginItemSetEnabled for earlier versions
        if #available(macOS 13.0, *) {
            do {
                let service = SMAppService.mainApp
                if enabled {
                    if service.status == .notRegistered {
                        try service.register()
                    }
                } else {
                    if service.status == .enabled {
                        try service.unregister()
                    }
                }
            } catch {
                print("Failed to set launch at login: \(error)")
            }
        } else {
            // Fallback for earlier macOS versions
            if let bundleID = Bundle.main.bundleIdentifier {
                SMLoginItemSetEnabled(bundleID as CFString, enabled)
            }
        }
    }
}

struct ShortcutPreferencesView: View {
    var body: some View {
        Form {
            Section(header: Text("Keyboard Shortcuts")) {
                HStack {
                    Text("Copy to Stack:")
                    Spacer()
                    KeyboardShortcuts.Recorder(for: .stackCopy)
                }
                
                HStack {
                    Text("Paste from Stack:")
                    Spacer()
                    KeyboardShortcuts.Recorder(for: .stackPaste)
                }
                
                HStack {
                    Text("Delete from Stack:")
                    Spacer()
                    KeyboardShortcuts.Recorder(for: .stackDelete)
                }
            }
            
            Text("Note: The app needs accessibility permissions to detect keyboard shortcuts.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top)
        }
        .padding()
    }
}
