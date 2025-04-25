//
//  PopupManager.swift
//  stack-copy
//
//  Created by Tirth Patel on 2025-04-24.
//

import Cocoa
import SwiftUI

enum PopupMode {
    case paste, delete
}

class PopupManager {
    private var popupWindow: NSWindow?
    private var completionHandler: ((Int?) -> Void)?
    private var eventMonitor: Any?
    
    func showPopup(items: [ClipboardItem], mode: PopupMode, completion: @escaping (Int?) -> Void) {
        self.completionHandler = completion
        
        // Create popup window
        let popupWindow = PopupWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: min(50 * items.count + (mode == .delete ? 50 : 0), 400)),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        popupWindow.backgroundColor = .clear
        popupWindow.isOpaque = false
        popupWindow.hasShadow = true
        popupWindow.level = .popUpMenu
        
        // Get front-most window and position relative to it
        if let frontWindow = NSApp.keyWindow ?? NSApp.mainWindow {
            let windowFrame = frontWindow.frame
            let centerX = windowFrame.midX
            let centerY = windowFrame.midY
            popupWindow.setFrameOrigin(NSPoint(x: centerX - 150, y: centerY - 200))
        } else {
            // Fallback to mouse position if no active window
            let mouseLocation = NSEvent.mouseLocation
            popupWindow.setFrameOrigin(NSPoint(x: mouseLocation.x - 150, y: mouseLocation.y - 20))
        }
        
        // Create and set content view
        let contentView = ClipboardPopupView(items: items, mode: mode) { [weak self] index in
            self?.handleSelection(index: index)
        }
        
        popupWindow.contentView = NSHostingView(rootView: contentView)
        
        popupWindow.makeKeyAndOrderFront(nil)
        
        // Setup event monitor to dismiss on other key presses
        setupEventMonitor()
        
        self.popupWindow = popupWindow
    }
    
    private func setupEventMonitor() {
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            // Handle number keys 1-0 (for 10th item)
            if let characters = event.charactersIgnoringModifiers {
                if let number = Int(characters), number >= 0, number <= 9 {
                    // Handle 0 as 10th item or delete all depending on mode
                    let index = number == 0 ? 9 : number - 1
                    self?.handleSelection(index: index)
                    return nil
                }
            }
            
            // Any other key dismisses without selection
            self?.dismissPopup(with: nil)
            return nil
        }
    }
    
    private func handleSelection(index: Int) {
        dismissPopup(with: index)
    }
    
    private func dismissPopup(with index: Int?) {
        if let eventMonitor = eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
            self.eventMonitor = nil
        }
        
        popupWindow?.close()
        popupWindow = nil
        
        // Small delay to ensure window is fully dismissed before callback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.completionHandler?(index)
            self.completionHandler = nil
        }
    }
}
