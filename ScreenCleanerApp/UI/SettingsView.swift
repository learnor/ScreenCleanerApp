//
//  SettingsView.swift
//  ScreenCleanerApp
//
//  Created by Claude on 2026-02-12.
//

import SwiftUI

struct SettingsView: View {
    @State private var hasPermission = PermissionManager.shared.checkAccessibilityPermission()
    @ObservedObject private var preferences = UserPreferences.shared

    var body: some View {
        VStack(spacing: 18) {
            // Header
            VStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 44))
                    .foregroundColor(.blue)

                Text("ScreenCleanerApp")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("版本 \(Constants.version)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 8)

            Divider()

            // Hotkeys section
            GroupBox(label: Label("快捷键", systemImage: "keyboard").font(.subheadline)) {
                VStack(spacing: 14) {
                    // Toggle clean mode hotkey
                    VStack(alignment: .leading, spacing: 6) {
                        Text("切换清洁模式（开启/关闭）")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        HotKeyRecorder(
                            keyCode: $preferences.toggleHotkeyKeyCode,
                            modifiers: $preferences.toggleHotkeyModifiers,
                            title: "切换清洁模式"
                        )
                    }

                    Divider()

                    // Reset button
                    HStack {
                        Spacer()
                        Button(action: {
                            preferences.resetToDefaults()
                        }) {
                            Label("恢复默认", systemImage: "arrow.counterclockwise")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
                .padding(10)
            }

            // Permissions section
            GroupBox(label: Label("权限", systemImage: "lock.shield").font(.subheadline)) {
                HStack {
                    Text("辅助功能")
                        .font(.caption)

                    Spacer()

                    if hasPermission {
                        Label("已授予", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Button("授予") {
                            PermissionManager.shared.openSystemPreferences()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                }
                .padding(10)
            }

            // Tips section
            GroupBox(label: Label("提示", systemImage: "lightbulb.fill").font(.subheadline)) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .top, spacing: 6) {
                        Text("•")
                        Text("点击录制框自定义快捷键")
                    }
                    HStack(alignment: .top, spacing: 6) {
                        Text("•")
                        Text("使用相同快捷键开启或关闭清洁模式")
                    }
                    HStack(alignment: .top, spacing: 6) {
                        Text("•")
                        Text("备用退出：连续按 ESC 9次（可以有间隔）")
                            .foregroundColor(.orange)
                    }
                    HStack(alignment: .top, spacing: 6) {
                        Text("•")
                        Text("修改后立即生效")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(10)
            }

            Spacer()

            // Footer
            Text("Made with ❤️")
                .font(.caption2)
                .foregroundColor(.secondary.opacity(0.6))
        }
        .padding(16)
        .frame(width: 460, height: 520)
        .onAppear {
            hasPermission = PermissionManager.shared.checkAccessibilityPermission()
        }
    }
}

#Preview {
    SettingsView()
}
