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

        // Configure window properties based on user preference
        let color = UserPreferences.shared.overlayColor.nsColor
        self.backgroundColor = color
        self.isOpaque = true
        self.level = .statusBar + 1        // Highest level to cover everything
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.ignoresMouseEvents = false    // Capture mouse events to prevent clicks

        // Prevent standard window behavior
        self.isMovable = false
        self.isReleasedWhenClosed = false
        self.acceptsMouseMovedEvents = true

        // Start with transparent for fade-in animation
        self.alphaValue = 0

        // Perform fade-in animation
        fadeIn()
    }

    /// Fade-in animation when window appears
    private func fadeIn() {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.animator().alphaValue = 1.0
        })
    }

    /// Fade-out animation before closing
    func fadeOutAndClose() {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            self.animator().alphaValue = 0
        }, completionHandler: {
            self.close()
        })
    }

    // Disable all standard window controls
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}
