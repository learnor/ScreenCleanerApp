//
//  PermissionManager.swift
//  ScreenCleanerApp
//
//  Created by Claude on 2026-02-12.
//

import ApplicationServices
import AppKit

/// Manages Accessibility permission required for keyboard interception
class PermissionManager {
    static let shared = PermissionManager()

    private init() {}

    /// Check if Accessibility permission is granted
    func checkAccessibilityPermission() -> Bool {
        return AXIsProcessTrusted()
    }

    /// Request Accessibility permission (shows system prompt)
    func requestAccessibilityPermission() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let _ = AXIsProcessTrustedWithOptions(options)
    }

    /// Open System Preferences to Accessibility settings
    func openSystemPreferences() {
        // For macOS 13+, use the new Settings app
        if #available(macOS 13, *) {
            let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
            NSWorkspace.shared.open(url)
        } else {
            let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
            NSWorkspace.shared.open(url)
        }
    }
}
