//
//  KeyboardShortcutExtension.swift
//  stack-copy
//
//  Created by Tirth Patel on 2025-04-24.
//

import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let stackCopy = Self("stackCopy", default: .init(.c, modifiers: [.command, .shift]))
    static let stackPaste = Self("stackPaste", default: .init(.v, modifiers: [.command, .shift]))
    static let stackDelete = Self("stackDelete", default: .init(.d, modifiers: [.command, .shift]))
}
