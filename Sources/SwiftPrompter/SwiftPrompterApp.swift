import AppKit
import SwiftUI

@main
struct SwiftPrompterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    @StateObject private var model = AppModel.shared

    var body: some Scene {
        Window("Swift Prompter", id: "main") {
            MainView(model: model, speech: model.speech)
        }
        .defaultSize(width: 960, height: 740)
        .commands {
            CommandGroup(after: .windowArrangement) {
                Button("Make Overlay Interactive") {
                    model.clickThrough = false
                    model.updateOverlay()
                }.keyboardShortcut("i", modifiers: [.command, .shift])
            }
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard AppModel.shared.speech.phase != .idle else { return .terminateNow }
        Task {
            await AppModel.shared.speech.stop()
            sender.reply(toApplicationShouldTerminate: true)
        }
        return .terminateLater
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}
