import SwiftUI

// MARK: - Simple Double-Click Handler

/// Simple double-click detection using direct event interception.
/// Note: This may interfere with control-click context menus.
struct SimpleDoubleClickModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content.overlay {
            SimpleDoubleClickOverlay(action: action)
        }
    }
}

private struct SimpleDoubleClickOverlay: NSViewRepresentable {
    let action: () -> Void

    func makeNSView(context: Context) -> SimpleDoubleClickNSView {
        let view = SimpleDoubleClickNSView()
        view.action = action
        return view
    }

    func updateNSView(_ nsView: SimpleDoubleClickNSView, context: Context) {
        nsView.action = action
    }
}

final class SimpleDoubleClickNSView: NSView {
    var action: (() -> Void)?

    override func mouseDown(with event: NSEvent) {
        if event.clickCount == 2 {
            action?()
        } else {
            super.mouseDown(with: event)
        }
    }

    override func rightMouseDown(with event: NSEvent) {
        nextResponder?.rightMouseDown(with: event)
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        return frame.contains(point) ? self : nil
    }
}

// MARK: - Complex Double-Click Handler

/// Complex double-click detection using event monitoring.
/// Supports control-click for context menus but uses more resources.
struct ComplexDoubleClickModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content.background {
            ComplexDoubleClickDetector(action: action)
        }
    }
}

private struct ComplexDoubleClickDetector: NSViewRepresentable {
    let action: () -> Void

    func makeNSView(context: Context) -> NSView {
        let view = ComplexDoubleClickMonitorView()
        view.action = action
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        (nsView as? ComplexDoubleClickMonitorView)?.action = action
    }
}

final class ComplexDoubleClickMonitorView: NSView {
    var action: (() -> Void)?
    private var monitor: Any?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if window != nil {
            startMonitoring()
        } else {
            stopMonitoring()
        }
    }

    private func startMonitoring() {
        guard monitor == nil else { return }
        monitor = NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
            self?.handleMouseDown(event)
            return event
        }
    }

    private func stopMonitoring() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }

    private func handleMouseDown(_ event: NSEvent) {
        guard event.clickCount == 2,
              !event.modifierFlags.contains(.control),
              let window = self.window else { return }

        let locationInWindow = event.locationInWindow
        let locationInView = convert(locationInWindow, from: nil)

        if bounds.contains(locationInView) {
            action?()
        }
    }

    deinit {
        stopMonitoring()
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        return nil
    }
}

// MARK: - View Extension

extension View {
    /// Adds a double-click handler that doesn't interfere with single-click selection.
    /// Uses the simple implementation (control-click may not work for context menus).
    func onDoubleClick(perform action: @escaping () -> Void) -> some View {
        modifier(SimpleDoubleClickModifier(action: action))
    }

    /// Adds a double-click handler with full control-click support.
    /// Uses event monitoring which may use more resources.
    func onDoubleClickComplex(perform action: @escaping () -> Void) -> some View {
        modifier(ComplexDoubleClickModifier(action: action))
    }
}
