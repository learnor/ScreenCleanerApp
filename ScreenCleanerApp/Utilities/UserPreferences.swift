//
//  UserPreferences.swift
//  ScreenCleanerApp
//
//  Created by Claude on 2026-02-12.
//

import Foundation
import AppKit
import ServiceManagement

/// Manages user preferences and settings
class UserPreferences: ObservableObject {
    static let shared = UserPreferences()

    private let defaults = UserDefaults.standard

    // Keys for UserDefaults
    private enum Keys {
        static let toggleHotkeyKeyCode = "toggleHotkeyKeyCode"
        static let toggleHotkeyModifiers = "toggleHotkeyModifiers"
        static let launchAtLogin = "launchAtLogin"
        static let overlayColor = "overlayColor"
        static let soundEffectsEnabled = "soundEffectsEnabled"
        static let notificationsEnabled = "notificationsEnabled"
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

    @Published var launchAtLogin: Bool {
        didSet {
            defaults.set(launchAtLogin, forKey: Keys.launchAtLogin)
            updateLoginItem()
        }
    }

    @Published var overlayColor: OverlayColor {
        didSet {
            defaults.set(overlayColor.rawValue, forKey: Keys.overlayColor)
        }
    }

    @Published var soundEffectsEnabled: Bool {
        didSet {
            defaults.set(soundEffectsEnabled, forKey: Keys.soundEffectsEnabled)
        }
    }

    @Published var notificationsEnabled: Bool {
        didSet {
            defaults.set(notificationsEnabled, forKey: Keys.notificationsEnabled)
        }
    }

    /// Get display string for current hotkey
    var hotkeyDisplayString: String {
        formatHotkey(keyCode: toggleHotkeyKeyCode, modifiers: toggleHotkeyModifiers)
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

        // Load other preferences
        self.launchAtLogin = defaults.bool(forKey: Keys.launchAtLogin)
        self.soundEffectsEnabled = defaults.object(forKey: Keys.soundEffectsEnabled) == nil ? true : defaults.bool(forKey: Keys.soundEffectsEnabled)
        self.notificationsEnabled = defaults.object(forKey: Keys.notificationsEnabled) == nil ? true : defaults.bool(forKey: Keys.notificationsEnabled)

        if let colorString = defaults.string(forKey: Keys.overlayColor),
           let color = OverlayColor(rawValue: colorString) {
            self.overlayColor = color
        } else {
            self.overlayColor = .black
        }
    }

    /// Reset to default hotkeys
    func resetToDefaults() {
        toggleHotkeyKeyCode = defaultToggleKeyCode
        toggleHotkeyModifiers = NSEvent.ModifierFlags(rawValue: defaultToggleModifiers)
    }

    /// Update login item status
    private func updateLoginItem() {
        #if os(macOS)
        if #available(macOS 13.0, *) {
            do {
                if launchAtLogin {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("❌ Failed to update login item: \(error)")
            }
        }
        #endif
    }
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

// MARK: - Overlay Color

enum OverlayColor: String, CaseIterable, Identifiable {
    case black = "black"
    case darkGray = "darkGray"
    case white = "white"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .black: return "黑色"
        case .darkGray: return "深灰色"
        case .white: return "白色"
        }
    }

    var nsColor: NSColor {
        switch self {
        case .black: return .black
        case .darkGray: return NSColor(white: 0.15, alpha: 1.0)
        case .white: return .white
        }
    }
}
