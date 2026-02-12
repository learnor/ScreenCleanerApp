//
//  Constants.swift
//  ScreenCleanerApp
//
//  Created by Claude on 2026-02-12.
//

import Foundation

enum Constants {
    // Hotkey configuration
    static let startHotKeyCode: UInt32 = 37  // L key

    // App info
    static let appName = "ScreenCleanerApp"
    static let version = "1.0.0"

    // User-facing strings
    enum Strings {
        static let startCleanMode = "开始清洁 (⌘⇧L)"
        static let exitCleanMode = "退出清洁模式：⌘ + ⌥ + Esc"
        static let permissionGranted = "✓ 权限已授予"
        static let permissionNeeded = "⚠️ 需要授予权限..."
        static let settings = "设置..."
        static let quit = "退出"
    }
}
