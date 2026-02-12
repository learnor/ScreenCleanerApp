//
//  UserPreferences.swift
//  ScreenCleanerApp
//
//  Created by Claude on 2026-02-12.
//

import Foundation
import AppKit

/// Manages user preferences and settings
class UserPreferences: ObservableObject {
    static let shared = UserPreferences()

    private let defaults = UserDefaults.standard

    // Keys for UserDefaults
    private enum Keys {
        static let toggleHotkeyKeyCode = "toggleHotkeyKeyCode"
        static let toggleHotkeyModifiers = "toggleHotkeyModifiers"
    }

    // Default values (toggle clean mode)
    private let defaultToggleKeyCode: UInt32 = 37  // L key
    private let defaultToggleModifiers: UInt = NSEvent.ModifierFlags([.command, .shift]).rawValue

    // Published properties for SwiftUI
    @Published var toggleHotkeyKeyCode: UInt32 {
        didSet {
            defaults.set(toggleHotkeyKeyCode, forKey: Keys.toggleHotkeyKeyCode)
            NotificationCenter.default.post(name: .hotkeyChanged, object: nil)
        }
    }

    @Published var toggleHotkeyModifiers: NSEvent.ModifierFlags {
        didSet {
            defaults.set(toggleHotkeyModifiers.rawValue, forKey: Keys.toggleHotkeyModifiers)
            NotificationCenter.default.post(name: .hotkeyChanged, object: nil)
        }
    }

    private init() {
        // Load toggle hotkey
        if defaults.object(forKey: Keys.toggleHotkeyKeyCode) != nil {
            self.toggleHotkeyKeyCode = UInt32(defaults.integer(forKey: Keys.toggleHotkeyKeyCode))
            self.toggleHotkeyModifiers = NSEvent.ModifierFlags(rawValue: UInt(defaults.integer(forKey: Keys.toggleHotkeyModifiers)))
        } else {
            self.toggleHotkeyKeyCode = defaultToggleKeyCode
            self.toggleHotkeyModifiers = NSEvent.ModifierFlags(rawValue: defaultToggleModifiers)
        }
    }

    /// Reset to default hotkeys
    func resetToDefaults() {
        toggleHotkeyKeyCode = defaultToggleKeyCode
        toggleHotkeyModifiers = NSEvent.ModifierFlags(rawValue: defaultToggleModifiers)
    }
}

// Notification for hotkey changes
extension Notification.Name {
    static let hotkeyChanged = Notification.Name("hotkeyChanged")
}

// Helper to convert key code and modifiers to string
extension UserPreferences {
    func formatHotkey(keyCode: UInt32, modifiers: NSEvent.ModifierFlags) -> String {
        var parts: [String] = []

        if modifiers.contains(.control) { parts.append("⌃") }
        if modifiers.contains(.option) { parts.append("⌥") }
        if modifiers.contains(.shift) { parts.append("⇧") }
        if modifiers.contains(.command) { parts.append("⌘") }

        parts.append(keyCodeToString(keyCode))

        return parts.joined(separator: " + ")
    }

    private func keyCodeToString(_ keyCode: UInt32) -> String {
        switch keyCode {
        case 0: return "A"
        case 11: return "B"
        case 8: return "C"
        case 2: return "D"
        case 14: return "E"
        case 3: return "F"
        case 5: return "G"
        case 4: return "H"
        case 34: return "I"
        case 38: return "J"
        case 40: return "K"
        case 37: return "L"
        case 46: return "M"
        case 45: return "N"
        case 31: return "O"
        case 35: return "P"
        case 12: return "Q"
        case 15: return "R"
        case 1: return "S"
        case 17: return "T"
        case 32: return "U"
        case 9: return "V"
        case 13: return "W"
        case 7: return "X"
        case 16: return "Y"
        case 6: return "Z"
        case 53: return "Esc"
        case 36: return "Return"
        case 48: return "Tab"
        case 49: return "Space"
        case 51: return "Delete"
        default: return "Key\(keyCode)"
        }
    }
}
