//
//  HotKeyManager.swift
//  ScreenCleanerApp
//
//  Created by Claude on 2026-02-12.
//

import Carbon
import AppKit

/// Manages global hotkey registration
class HotKeyManager {
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private var callback: (() -> Void)?

    // Store registration parameters for re-registration
    private var savedKeyCode: UInt32?
    private var savedModifiers: NSEvent.ModifierFlags?

    /// Register a global hotkey
    func registerHotKey(keyCode: UInt32, modifiers: NSEvent.ModifierFlags, callback: @escaping () -> Void) {
        // Unregister any existing hotkey first
        unregisterHotKey()

        self.callback = callback
        self.savedKeyCode = keyCode
        self.savedModifiers = modifiers

        var hotKeyID = EventHotKeyID(signature: FourCharCode("SCLR".fourCharCodeValue), id: 1)
        var carbonModifiers: UInt32 = 0

        // Convert NSEvent.ModifierFlags to Carbon modifiers
        if modifiers.contains(.command) { carbonModifiers |= UInt32(cmdKey) }
        if modifiers.contains(.shift) { carbonModifiers |= UInt32(shiftKey) }
        if modifiers.contains(.option) { carbonModifiers |= UInt32(optionKey) }
        if modifiers.contains(.control) { carbonModifiers |= UInt32(controlKey) }

        // Register the hotkey
        let status = RegisterEventHotKey(
            keyCode,
            carbonModifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        if status != noErr {
            print("❌ Failed to register hotkey: \(status)")
            return
        }

        // Install event handler
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let handlerCallback: EventHandlerUPP = { _, _, userData in
            guard let userData = userData else { return OSStatus(eventNotHandledErr) }
            let manager = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()

            DispatchQueue.main.async {
                manager.callback?()
            }
            return noErr
        }

        InstallEventHandler(
            GetApplicationEventTarget(),
            handlerCallback,
            1,
            &eventType,
            UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
            &eventHandler
        )

        print("✅ Hotkey registered: keyCode=\(keyCode), modifiers=\(carbonModifiers)")
    }

    /// Unregister the hotkey
    private func unregisterHotKey() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
            print("🗑️ Hotkey unregistered")
        }
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
    }

    /// Temporarily disable the hotkey (actually unregisters it)
    func disable() {
        unregisterHotKey()
        print("🔇 Hotkey disabled (unregistered)")
    }

    /// Re-enable the hotkey (re-registers it)
    func enable() {
        guard let keyCode = savedKeyCode,
              let modifiers = savedModifiers,
              let callback = callback else {
            print("⚠️ Cannot re-enable: missing saved parameters")
            return
        }
        registerHotKey(keyCode: keyCode, modifiers: modifiers, callback: callback)
        print("🔊 Hotkey enabled (re-registered)")
    }

    deinit {
        unregisterHotKey()
    }
}

// Helper extension to convert String to FourCharCode
extension String {
    var fourCharCodeValue: FourCharCode {
        var result: FourCharCode = 0
        if let data = self.data(using: .macOSRoman) {
            data.withUnsafeBytes { bytes in
                let buffer = bytes.bindMemory(to: UInt8.self)
                for i in 0..<min(4, buffer.count) {
                    result = result << 8 + FourCharCode(buffer[i])
                }
            }
        }
        return result
    }
}
