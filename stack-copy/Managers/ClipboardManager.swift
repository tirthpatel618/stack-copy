//
//  ClipboardManager.swift
//  stack-copy
//
//  Created by Tirth Patel on 2025-04-24.
//


import Cocoa
import SwiftUI
import Combine
import UserNotifications

class ClipboardManager: ObservableObject {
    static let shared = ClipboardManager()
    
    @Published var clipboardStack: [ClipboardItem] = []
    private let popupManager = PopupManager()
    
    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int
    
    @AppStorage(Constants.UserDefaults.maxStackSizeKey) 
    private var maxStackSize: Int = Constants.defaultMaxStackSize
    
    private init() {
        self.lastChangeCount = pasteboard.changeCount
        loadStack()
    }
    
    // allow user default stacks
    func saveStack() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(clipboardStack)
            UserDefaults.standard.set(data, forKey: Constants.UserDefaults.clipboardStackKey)
        } catch {
            print("Failed to save clipboard stack: \(error)")
        }
    }
    
    // loading user default stacks
    private func loadStack() {
        if let data = UserDefaults.standard.data(forKey: Constants.UserDefaults.clipboardStackKey) {
            do {
                let decoder = JSONDecoder()
                clipboardStack = try decoder.decode([ClipboardItem].self, from: data)
            } catch {
                print("Failed to load clipboard stack: \(error)")
                clipboardStack = []
            }
        }
    }
    
    
    func copyToStack() {
        guard clipboardStack.count < maxStackSize else {
            showStackFullNotification()
            return
        }
        
        // Check if pasteboard has changed
        if pasteboard.changeCount == lastChangeCount {
            return
        }
        
        lastChangeCount = pasteboard.changeCount
        
        // Create item based on pasteboard contents
        if let item = createItemFromPasteboard() {
            clipboardStack.insert(item, at: 0)
            saveStack()
        }
    }
    
    private func createItemFromPasteboard() -> ClipboardItem? {
        // Check for text
        if let text = pasteboard.string(forType: .string) {
            return ClipboardItem(
                contentType: .text,
                textData: text
            )
        }
        
        // Check for image
        if let image = pasteboard.data(forType: .tiff) ?? pasteboard.data(forType: .png) {
            return ClipboardItem(
                contentType: .image,
                imageData: image
            )
        }
        
        // Check for file URLs
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self]) as? [URL] {
            return ClipboardItem(
                contentType: .fileURL,
                fileURLData: urls
            )
        }
        
        // Check for RTF
        if let rtfData = pasteboard.data(forType: .rtf) {
            return ClipboardItem(
                contentType: .rtf,
                rtfData: rtfData
            )
        }
        
        return nil
    }
    
    // Show popup for paste selection
    func showPastePopup() {
        popupManager.showPopup(items: clipboardStack, mode: .paste) { [weak self] index in
            guard let self = self else { return }
            
            if let index = index, index >= 0, index < self.clipboardStack.count {
                self.pasteItemAtIndex(index)
            }
        }
    }
    
    // Show popup for delete selection
    func showDeletePopup() {
        popupManager.showPopup(items: clipboardStack, mode: .delete) { [weak self] index in
            guard let self = self else { return }
            
            if let index = index {
                if index == -1 {
                    // Delete all (special index)
                    self.clipboardStack.removeAll()
                    self.saveStack()
                } else if index >= 0, index < self.clipboardStack.count {
                    // Delete specific item
                    self.clipboardStack.remove(at: index)
                    self.saveStack()
                }
            }
        }
    }
    
    // Paste item at specific index
    private func pasteItemAtIndex(_ index: Int) {
        let item = clipboardStack[index]
        
        // Clear pasteboard
        pasteboard.clearContents()
        
        // Copy appropriate data based on content type
        switch item.contentType {
        case .text:
            if let text = item.textData {
                pasteboard.setString(text, forType: .string)
            }
        case .image:
            if let imageData = item.imageData {
                pasteboard.setData(imageData, forType: .tiff)
            }
        case .fileURL:
            if let urls = item.fileURLData {
                pasteboard.writeObjects(urls as [NSURL])
            }
        case .rtf:
            if let rtfData = item.rtfData {
                pasteboard.setData(rtfData, forType: .rtf)
            }
        }
        
        // Simulate paste command
        simulatePasteCommand()
    }
    
    // Simulate Cmd+V to paste
    private func simulatePasteCommand() {
        let source = CGEventSource(stateID: .hidSystemState)
        
        // Cmd+V key down
        let keyVDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
        keyVDown?.flags = .maskCommand
        
        // Cmd+V key up
        let keyVUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        keyVUp?.flags = .maskCommand
        
        // Post events
        keyVDown?.post(tap: .cghidEventTap)
        keyVUp?.post(tap: .cghidEventTap)
    }
    
    // Display notification when stack is full
    private func showStackFullNotification() {
        let content = UNMutableNotificationContent()
        content.title = Constants.Notifications.stackFullTitle
        content.body = Constants.Notifications.stackFullMessage
        
        // Create a request with immediate trigger
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil 
        )
        
        // Add request to notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error displaying notification: \(error)")
            }
        }
    }
}
