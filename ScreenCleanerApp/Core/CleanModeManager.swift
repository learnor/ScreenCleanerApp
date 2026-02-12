//
//  CleanModeManager.swift
//  ScreenCleanerApp
//
//  Created by Claude on 2026-02-12.
//

import SwiftUI
import AppKit

/// Coordinates the clean mode functionality (full-screen windows + keyboard interception)
class CleanModeManager: ObservableObject {
    @Published var isCleanModeActive = false

    private var fullScreenWindows: [FullScreenWindow] = []
    private var keyboardInterceptor: KeyboardInterceptor?

    /// Toggle clean mode (start if inactive, stop if active)
    func toggleCleanMode() {
        if isCleanModeActive {
            stopCleanMode()
        } else {
            startCleanMode()
        }
    }

    /// Start clean mode
    func startCleanMode() {
        guard !isCleanModeActive else {
            print("⚠️ Clean mode already active")
            return
        }

        // Check for Accessibility permission
        guard PermissionManager.shared.checkAccessibilityPermission() else {
            print("❌ Accessibility permission not granted")
            showPermissionAlert()
            return
        }

        print("🚀 Starting clean mode...")

        // 1. Create full-screen windows for all screens
        fullScreenWindows = NSScreen.screens.map { screen in
            let window = FullScreenWindow(screen: screen)
            window.orderFrontRegardless()
            return window
        }

        // 2. Start keyboard interception
        let preferences = UserPreferences.shared
        keyboardInterceptor = KeyboardInterceptor()
        keyboardInterceptor?.exitKeyCode = CGKeyCode(preferences.toggleHotkeyKeyCode)
        keyboardInterceptor?.exitModifiers = preferences.toggleHotkeyModifiers
        keyboardInterceptor?.onExitCleanMode = { [weak self] in
            print("🔑 Toggle hotkey detected - exiting clean mode")
            self?.stopCleanMode()
        }
        keyboardInterceptor?.start()

        isCleanModeActive = true

        // 3. Play startup sound (optional)
        NSSound(named: "Purr")?.play()

        print("✅ Clean mode activated")
    }

    /// Stop clean mode
    func stopCleanMode() {
        guard isCleanModeActive else {
            print("⚠️ Clean mode not active")
            return
        }

        print("🛑 Stopping clean mode...")

        // Stop keyboard interception
        keyboardInterceptor?.stop()
        keyboardInterceptor = nil

        // Close all windows
        fullScreenWindows.forEach { $0.close() }
        fullScreenWindows.removeAll()

        isCleanModeActive = false

        // Play exit sound (optional)
        NSSound(named: "Pop")?.play()

        print("✅ Clean mode deactivated")
    }

    /// Show alert when permission is not granted
    private func showPermissionAlert() {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "需要辅助功能权限"
            alert.informativeText = "ScreenCleanerApp 需要辅助功能权限以拦截键盘输入。\n\n点击\"打开设置\"前往系统设置进行授权。"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "打开设置")
            alert.addButton(withTitle: "稍后")

            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                PermissionManager.shared.openSystemPreferences()
            }
        }
    }
}
