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
        print("DEBUG: copyToStack called")
        guard clipboardStack.count < maxStackSize else {
            print("DEBUG: Stack is full, showing notification")
            showStackFullNotification()
            return
        }
        
        // Store the original change count to detect if our copy succeeded
        let originalChangeCount = pasteboard.changeCount
        print("DEBUG: Original pasteboard change count: \(originalChangeCount)")
        
        // Simulate standard copy command (Cmd+C) to get current selection
        DispatchQueue.main.async {
            let source = CGEventSource(stateID: .hidSystemState)
            let keyCDown = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: true)
            keyCDown?.flags = .maskCommand
            let keyCUp = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: false)
            keyCUp?.flags = .maskCommand
            
            // Execute the copy command
            keyCDown?.post(tap: .cghidEventTap)
            keyCUp?.post(tap: .cghidEventTap)
            
            // Slightly longer delay to allow pasteboard to update
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                guard let self = self else { return }
                
                print("DEBUG: Pasteboard change count after copy: \(self.pasteboard.changeCount)")
                
                // Try to create item regardless of change count
                print("DEBUG: Attempting to create item from pasteboard anyway")
                if let item = self.createItemFromPasteboard() {
                    print("DEBUG: Successfully created clipboard item of type: \(item.contentType)")
                    self.clipboardStack.insert(item, at: 0)
                    self.saveStack()
                    print("DEBUG: Current stack size after adding: \(self.clipboardStack.count)")
                } else {
                    print("DEBUG: Failed to create clipboard item from pasteboard - nothing to copy")
                }
                
                // Update last change count
                self.lastChangeCount = self.pasteboard.changeCount
            }
        }
    }

    private func createItemFromPasteboard() -> ClipboardItem? {
        // Check for text
        if let text = pasteboard.string(forType: .string) {
            print("DEBUG: Found text in pasteboard: \(text.prefix(20))...")
            return ClipboardItem(
                contentType: .text,
                textData: text
            )
        }
        
        // Check for image
        if let image = pasteboard.data(forType: .tiff) ?? pasteboard.data(forType: .png) {
            print("DEBUG: Found image data in pasteboard, size: \(image.count) bytes")
            return ClipboardItem(
                contentType: .image,
                imageData: image
            )
        }
        
        // Check for file URLs
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self]) as? [URL] {
            print("DEBUG: Found file URLs in pasteboard: \(urls.count) URLs")
            return ClipboardItem(
                contentType: .fileURL,
                fileURLData: urls
            )
        }
        
        // Check for RTF
        if let rtfData = pasteboard.data(forType: .rtf) {
            print("DEBUG: Found RTF data in pasteboard, size: \(rtfData.count) bytes")
            return ClipboardItem(
                contentType: .rtf,
                rtfData: rtfData
            )
        }
        
        print("DEBUG: No supported content types found in pasteboard")
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
        // Ensure we're on the main thread
        DispatchQueue.main.async {
            let item = self.clipboardStack[index]
            
            // Clear pasteboard
            self.pasteboard.clearContents()
            
            // Copy appropriate data based on content type
            switch item.contentType {
            case .text:
                if let text = item.textData {
                    self.pasteboard.setString(text, forType: .string)
                }
            case .image:
                if let imageData = item.imageData {
                    self.pasteboard.setData(imageData, forType: .tiff)
                }
            case .fileURL:
                if let urls = item.fileURLData {
                    self.pasteboard.writeObjects(urls as [NSURL])
                }
            case .rtf:
                if let rtfData = item.rtfData {
                    self.pasteboard.setData(rtfData, forType: .rtf)
                }
            }
            
            // Add a small delay before simulating paste
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.simulatePasteCommand()
            }
        }
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
    
    func testManualCopy() {
        print("DEBUG: Manual copy test triggered")
        let originalLastChangeCount = lastChangeCount
        // Force ignore change count check
        lastChangeCount = -1
        copyToStack()
        if clipboardStack.isEmpty {
            print("DEBUG: Failed to add anything to stack even with forced copy")
        } else {
            print("DEBUG: Successfully added test item to stack")
        }
        // Restore original behavior
        lastChangeCount = originalLastChangeCount
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
