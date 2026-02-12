//
//  KeyboardInterceptor.swift
//  ScreenCleanerApp
//
//  Created by Claude on 2026-02-12.
//

import ApplicationServices
import AppKit

/// Intercepts and blocks all keyboard input except for the exit combination
class KeyboardInterceptor {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var mediaKeyMonitor: Any?  // For capturing media keys

    // Exit combination (configurable)
    var exitKeyCode: CGKeyCode = 53  // Default: Esc
    var exitModifiers: NSEvent.ModifierFlags = [.command, .shift]  // Default: Cmd + Shift

    // ESC press counter for backup exit
    private var escPressCount = 0
    private let escPressRequired = 9  // Need 9 consecutive presses (no time limit)

    /// Callback triggered when exit combination is pressed
    var onExitCleanMode: (() -> Void)?

    /// Start intercepting keyboard events
    func start() {
        // Create event mask for ALL events including media keys
        // NX_SYSDEFINED (14) is used for media keys
        let eventMask = (1 << CGEventType.keyDown.rawValue) |
                       (1 << CGEventType.keyUp.rawValue) |
                       (1 << CGEventType.flagsChanged.rawValue) |
                       (1 << 14)  // NX_SYSDEFINED for media keys

        // Event callback
        let callback: CGEventTapCallBack = { proxy, type, event, refcon in
            guard let refcon = refcon else { return nil }

            let interceptor = Unmanaged<KeyboardInterceptor>
                .fromOpaque(refcon)
                .takeUnretainedValue()

            // Handle system-defined events (media keys)
            if type.rawValue == 14 {  // NX_SYSDEFINED
                print("🎵 Media key event blocked")
                return nil  // Block media keys
            }

            // Check if this is the exit combination
            if interceptor.isExitCombination(event: event, type: type) {
                // Trigger exit callback on main thread
                DispatchQueue.main.async {
                    print("🔑 Exit combination detected")
                    interceptor.onExitCleanMode?()
                }
                // Allow this key event through
                return Unmanaged.passRetained(event)
            }

            // Check for consecutive ESC presses (backup exit)
            if type == .keyDown && interceptor.checkEscapeSequence(event: event) {
                DispatchQueue.main.async {
                    print("🔑 ESC sequence detected (9 consecutive presses)")
                    interceptor.onExitCleanMode?()
                }
                return nil
            }

            // Block all other keyboard events by returning nil
            return nil
        }

        // Create event tap with all events
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: callback,
            userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        )

        guard let eventTap = eventTap else {
            print("❌ Failed to create event tap - Accessibility permission not granted")
            return
        }

        // Add to RunLoop
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)

        // Install local media key monitor as additional layer
        // This catches media keys at NSEvent level
        mediaKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .systemDefined) { event in
            print("🎵 NSEvent media key blocked")
            return nil  // Block by returning nil
        }

        print("✅ Keyboard interceptor started")
        print("🎵 Media key blocking enabled")
        print("💡 Backup exit: Press ESC 9 times consecutively")
    }

    /// Stop intercepting keyboard events
    func stop() {
        // Reset ESC counter
        escPressCount = 0

        // Remove media key monitor
        if let monitor = mediaKeyMonitor {
            NSEvent.removeMonitor(monitor)
            mediaKeyMonitor = nil
        }

        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            CFMachPortInvalidate(eventTap)
        }
        if let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        }
        eventTap = nil
        runLoopSource = nil

        print("✅ Keyboard interceptor stopped")
    }

    /// Check for consecutive ESC presses
    private func checkEscapeSequence(event: CGEvent) -> Bool {
        let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))

        // Check if it's ESC key (keyCode 53)
        if keyCode == 53 {
            // Increment counter
            escPressCount += 1
            print("⌨️ ESC pressed: \(escPressCount)/\(escPressRequired)")

            // Check if we've reached the required count
            if escPressCount >= escPressRequired {
                print("✅ ESC exit sequence completed!")
                escPressCount = 0
                return true
            }
        } else {
            // Any other key resets the counter
            if escPressCount > 0 {
                print("⌨️ ESC sequence interrupted (pressed other key), resetting counter")
                escPressCount = 0
            }
        }

        return false
    }

    /// Check if the event is the exit combination
    private func isExitCombination(event: CGEvent, type: CGEventType) -> Bool {
        guard type == .keyDown else { return false }

        let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
        let flags = event.flags

        // Check if key code matches
        guard keyCode == exitKeyCode else { return false }

        // Check if all required modifiers are pressed
        var allModifiersMatch = true

        if exitModifiers.contains(.command) && !flags.contains(.maskCommand) {
            allModifiersMatch = false
        }
        if exitModifiers.contains(.option) && !flags.contains(.maskAlternate) {
            allModifiersMatch = false
        }
        if exitModifiers.contains(.shift) && !flags.contains(.maskShift) {
            allModifiersMatch = false
        }
        if exitModifiers.contains(.control) && !flags.contains(.maskControl) {
            allModifiersMatch = false
        }

        // Also check that no extra modifiers are pressed (except for non-coalesced flags)
        if allModifiersMatch {
            // Make sure the required modifiers are actually present
            let hasCommand = flags.contains(.maskCommand)
            let hasOption = flags.contains(.maskAlternate)
            let hasShift = flags.contains(.maskShift)
            let hasControl = flags.contains(.maskControl)

            let needsCommand = exitModifiers.contains(.command)
            let needsOption = exitModifiers.contains(.option)
            let needsShift = exitModifiers.contains(.shift)
            let needsControl = exitModifiers.contains(.control)

            return (hasCommand == needsCommand) &&
                   (hasOption == needsOption) &&
                   (hasShift == needsShift) &&
                   (hasControl == needsControl)
        }

        return false
    }

    deinit {
        stop()
    }
}
