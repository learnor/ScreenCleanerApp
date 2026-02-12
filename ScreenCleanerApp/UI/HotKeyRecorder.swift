//
//  HotKeyRecorder.swift
//  ScreenCleanerApp
//
//  Created by Claude on 2026-02-12.
//

import SwiftUI
import AppKit

/// A view for recording keyboard shortcuts
struct HotKeyRecorder: NSViewRepresentable {
    @Binding var keyCode: UInt32
    @Binding var modifiers: NSEvent.ModifierFlags
    let title: String

    func makeCoordinator() -> Coordinator {
        Coordinator(keyCode: $keyCode, modifiers: $modifiers)
    }

    func makeNSView(context: Context) -> HotKeyRecorderView {
        let view = HotKeyRecorderView()
        view.onHotKeyRecorded = context.coordinator.handleHotKeyRecorded
        view.title = title
        view.currentKeyCode = keyCode
        view.currentModifiers = modifiers
        return view
    }

    func updateNSView(_ nsView: HotKeyRecorderView, context: Context) {
        if nsView.currentKeyCode != keyCode || nsView.currentModifiers != modifiers {
            nsView.currentKeyCode = keyCode
            nsView.currentModifiers = modifiers
            nsView.updateDisplay()
        }
    }

    class Coordinator {
        var keyCode: Binding<UInt32>
        var modifiers: Binding<NSEvent.ModifierFlags>

        init(keyCode: Binding<UInt32>, modifiers: Binding<NSEvent.ModifierFlags>) {
            self.keyCode = keyCode
            self.modifiers = modifiers
        }

        func handleHotKeyRecorded(_ newKeyCode: UInt32, _ newModifiers: NSEvent.ModifierFlags) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                print("🔄 Coordinator updating: keyCode=\(newKeyCode), modifiers=\(newModifiers.rawValue)")
                self.keyCode.wrappedValue = newKeyCode
                self.modifiers.wrappedValue = newModifiers
            }
        }
    }
}

/// NSView that captures keyboard input for hotkey recording
class HotKeyRecorderView: NSView {
    var onHotKeyRecorded: ((UInt32, NSEvent.ModifierFlags) -> Void)?
    var title: String = ""
    var currentKeyCode: UInt32 = 0 {
        didSet {
            if !isRecording {
                updateDisplay()
            }
        }
    }
    var currentModifiers: NSEvent.ModifierFlags = [] {
        didSet {
            if !isRecording {
                updateDisplay()
            }
        }
    }

    private var isRecording = false
    private var monitor: Any?

    private lazy var button: NSButton = {
        let btn = NSButton()
        btn.bezelStyle = .rounded
        btn.alignment = .center
        btn.font = .systemFont(ofSize: 13)
        btn.target = self
        btn.action = #selector(buttonClicked)
        return btn
    }()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.heightAnchor.constraint(equalToConstant: 28)
        ])

        updateDisplay()
    }

    @objc private func buttonClicked() {
        if isRecording {
            cancelRecording()
        } else {
            startRecording()
        }
    }

    func updateDisplay() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            if self.isRecording {
                self.button.title = "按下快捷键... (按ESC取消)"
                self.button.contentTintColor = .systemBlue
            } else if self.currentKeyCode != 0 {
                self.button.title = self.formatHotkey()
                self.button.contentTintColor = nil
            } else {
                self.button.title = "点击录制快捷键"
                self.button.contentTintColor = nil
            }
        }
    }

    private func startRecording() {
        guard !isRecording else { return }

        print("🎙️ Started recording hotkey for: \(title)")
        isRecording = true
        updateDisplay()

        // Make window key
        window?.makeKey()

        // Install local event monitor
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return event }

            let keyCode = UInt32(event.keyCode)
            let modifiers = event.modifierFlags.intersection([.command, .option, .shift, .control])

            print("⌨️ Key: \(keyCode), mods: \(modifiers.rawValue)")

            // ESC cancels
            if keyCode == 53 && modifiers.isEmpty {
                print("❌ Cancelled")
                self.cancelRecording()
                return nil
            }

            // Need modifiers
            if !modifiers.isEmpty {
                print("✅ Recorded: \(keyCode) + \(modifiers.rawValue)")
                self.stopRecording(keyCode: keyCode, modifiers: modifiers)
                return nil
            }

            // No modifiers = beep
            NSSound.beep()
            return nil
        }

        print("✅ Monitor installed")
    }

    private func cancelRecording() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
        isRecording = false
        updateDisplay()
        print("🛑 Recording stopped")
    }

    private func stopRecording(keyCode: UInt32, modifiers: NSEvent.ModifierFlags) {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }

        isRecording = false
        currentKeyCode = keyCode
        currentModifiers = modifiers

        updateDisplay()

        // Notify callback
        print("📢 Notifying callback")
        onHotKeyRecorded?(keyCode, modifiers)
    }

    private func formatHotkey() -> String {
        var parts: [String] = []

        if currentModifiers.contains(.control) { parts.append("⌃") }
        if currentModifiers.contains(.option) { parts.append("⌥") }
        if currentModifiers.contains(.shift) { parts.append("⇧") }
        if currentModifiers.contains(.command) { parts.append("⌘") }

        parts.append(keyCodeToString(currentKeyCode))

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

    deinit {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
