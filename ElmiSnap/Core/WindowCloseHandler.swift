import AppKit

/// Window delegate that reports `windowWillClose` to a closure.
///
/// The callback is deferred to the next main-actor turn so the owner can drop
/// its references (window, handler) without releasing the handler while AppKit
/// is still executing inside it.
@MainActor
final class WindowCloseHandler: NSObject, NSWindowDelegate {
    private let onClose: @MainActor () -> Void

    init(onClose: @escaping @MainActor () -> Void) {
        self.onClose = onClose
    }

    func windowWillClose(_ notification: Notification) {
        let callback = onClose
        Task { @MainActor in callback() }
    }
}

/// A window together with the delegate that observes its closing.
@MainActor
struct ManagedWindow {
    let window: NSWindow
    let closeHandler: WindowCloseHandler
}
