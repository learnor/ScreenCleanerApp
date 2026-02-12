//
//  AppDelegate.swift
//  ScreenCleanerApp
//
//  Created by Claude on 2026-02-12.
//

import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var statusItem: NSStatusItem?
    var cleanModeManager = CleanModeManager()
    var hotKeyManager: HotKeyManager?
    var settingsWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("🚀 ScreenCleanerApp launched")

        setupMenuBar()
        setupGlobalHotKey()
        checkPermissions()

        // Listen for hotkey changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hotkeyChanged),
            name: .hotkeyChanged,
            object: nil
        )
    }

    private func setupMenuBar() {
        // Create menu bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "sparkles", accessibilityDescription: "Screen Cleaner")
        }

        // Create menu
        let menu = NSMenu()

        // Toggle clean mode item
        let toggleItem = NSMenuItem(
            title: "切换清洁模式",
            action: #selector(toggleCleanMode),
            keyEquivalent: ""
        )
        toggleItem.target = self
        menu.addItem(toggleItem)

        menu.addItem(NSMenuItem.separator())

        // Permission status item
        let permissionItem = NSMenuItem(
            title: checkPermissionStatus(),
            action: #selector(openPermissions),
            keyEquivalent: ""
        )
        permissionItem.target = self
        menu.addItem(permissionItem)

        menu.addItem(NSMenuItem.separator())

        // Settings item
        let settingsItem = NSMenuItem(
            title: Constants.Strings.settings,
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        // Quit item
        let quitItem = NSMenuItem(
            title: Constants.Strings.quit,
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu

        print("✅ Menu bar setup complete")
    }

    private func setupGlobalHotKey() {
        // Register hotkey using user preferences
        let preferences = UserPreferences.shared
        hotKeyManager = HotKeyManager()
        hotKeyManager?.registerHotKey(
            keyCode: preferences.toggleHotkeyKeyCode,
            modifiers: preferences.toggleHotkeyModifiers
        ) { [weak self] in
            print("🔑 Global toggle hotkey triggered")
            self?.cleanModeManager.toggleCleanMode()
        }
    }

    @objc private func hotkeyChanged() {
        print("⚙️ Hotkey changed, re-registering...")
        // Re-register hotkey with new settings
        hotKeyManager = nil  // This will unregister the old hotkey
        setupGlobalHotKey()
    }

    private func checkPermissions() {
        if !PermissionManager.shared.checkAccessibilityPermission() {
            // Delay to let UI settle
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showPermissionAlert()
            }
        }
    }

    @objc func toggleCleanMode() {
        print("📱 Menu: Toggle clean mode")
        cleanModeManager.toggleCleanMode()
    }

    @objc func startCleanMode() {
        print("📱 Menu: Start clean mode")
        cleanModeManager.startCleanMode()
    }

    @objc func openPermissions() {
        print("📱 Menu: Open permissions")
        PermissionManager.shared.openSystemPreferences()
    }

    @objc func openSettings() {
        print("📱 Menu: Open settings")

        // If window already exists, just show it
        if let window = settingsWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            // Disable hotkey when settings window is shown
            hotKeyManager?.disable()
            return
        }

        // Create a new settings window
        let settingsView = SettingsView()
        let hostingController = NSHostingController(rootView: settingsView)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 460, height: 520),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        window.title = "设置"
        window.contentViewController = hostingController
        window.center()
        window.isReleasedWhenClosed = false

        // Set delegate to handle window close
        window.delegate = self

        // Store reference
        settingsWindow = window

        // Disable hotkey while settings window is open
        hotKeyManager?.disable()

        // Show window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        print("✅ Settings window opened")
    }

    @objc func quit() {
        print("📱 Menu: Quit")
        NSApp.terminate(nil)
    }

    private func checkPermissionStatus() -> String {
        if PermissionManager.shared.checkAccessibilityPermission() {
            return Constants.Strings.permissionGranted
        } else {
            return Constants.Strings.permissionNeeded
        }
    }

    private func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "需要辅助功能权限"
        alert.informativeText = """
        ScreenCleanerApp 需要辅助功能权限以拦截键盘输入。

        这是实现清洁模式功能的必要权限，用于：
        • 屏蔽键盘输入防止误操作
        • 响应退出组合键（⌘ + ⇧ + Esc）

        点击"打开设置"前往系统设置进行授权。
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "打开设置")
        alert.addButton(withTitle: "稍后")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            PermissionManager.shared.openSystemPreferences()
        }
    }

    // MARK: - NSWindowDelegate

    func windowWillClose(_ notification: Notification) {
        // Re-enable hotkey when settings window closes
        if notification.object as? NSWindow === settingsWindow {
            hotKeyManager?.enable()
            print("✅ Settings window closed, hotkey re-enabled")
        }
    }
}
