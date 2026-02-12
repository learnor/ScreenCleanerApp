//
//  ScreenCleanerAppApp.swift
//  ScreenCleanerApp
//
//  Created by Claude on 2026-02-12.
//

import SwiftUI

@main
struct ScreenCleanerAppApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}
