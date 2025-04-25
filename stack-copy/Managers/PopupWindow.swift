//
//  PopupWindow.swift
//  stack-copy
//
//  Created by Tirth Patel on 2025-04-24.
//

import Cocoa

class PopupWindow: NSWindow {
  // allow this window to become the key (and main) window
  override var canBecomeKey: Bool { true }
  override var canBecomeMain: Bool { true }
}
