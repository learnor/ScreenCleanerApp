//
//  FullScreenWindow.swift
//  ScreenCleanerApp
//
//  Created by Claude on 2026-02-12.
//

import AppKit

/// Full-screen black overlay window that covers an entire screen
class FullScreenWindow: NSWindow {
    init(screen: NSScreen) {
        super.init(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        // Set the screen for this window
        self.setFrame(screen.frame, display: true)

        // Configure window properties
        self.backgroundColor = .black
        self.isOpaque = true
        self.level = .statusBar + 1        // Highest level to cover everything
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.ignoresMouseEvents = false    // Capture mouse events to prevent clicks

        // Prevent standard window behavior
        self.isMovable = false
        self.isReleasedWhenClosed = false
        self.acceptsMouseMovedEvents = true
    }

    // Disable all standard window controls
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}
