import AppKit
import SwiftUI

@MainActor
final class OverlayController {
    private let model: AppModel
    private var panel: NSPanel?

    init(model: AppModel) { self.model = model }

    func update() {
        guard model.overlayVisible else {
            panel?.orderOut(nil)
            return
        }
        if panel == nil { createPanel() }
        panel?.ignoresMouseEvents = model.clickThrough
        panel?.orderFrontRegardless()
    }

    func centerNearWebcam() {
        guard let panel, let screen = NSScreen.main ?? NSScreen.screens.first else { return }
        let frame = screen.visibleFrame
        panel.setFrameOrigin(NSPoint(x: frame.midX - panel.frame.width / 2,
                                     y: frame.maxY - panel.frame.height - 8))
    }

    private func createPanel() {
        let panel = NSPanel(contentRect: NSRect(x: 0, y: 0, width: 680, height: 260),
                            styleMask: [.borderless, .nonactivatingPanel, .resizable],
                            backing: .buffered, defer: false)
        panel.title = "Teleprompter Overlay"
        panel.isReleasedWhenClosed = false
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.hidesOnDeactivate = false
        panel.isMovableByWindowBackground = true
        panel.minSize = NSSize(width: 360, height: 160)
        panel.contentView = DraggableHostingView(rootView: OverlayView(model: model))
        self.panel = panel
        centerNearWebcam()
    }
}

private final class DraggableHostingView<Content: View>: NSHostingView<Content> {
    override var mouseDownCanMoveWindow: Bool { true }
}
