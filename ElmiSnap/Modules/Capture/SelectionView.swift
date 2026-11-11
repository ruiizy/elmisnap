import AppKit

/// Draws the dimmed screen and the rubber-band selection. Flipped, so the
/// selection rect is already top-left based (display-local, in points).
final class SelectionView: NSView {
    var displayID: CGDirectDisplayID = 0
    var onSelect: (@MainActor (CaptureRegion) -> Void)?
    var onCancel: (@MainActor () -> Void)?

    private static let escapeKeyCode: UInt16 = 53
    private static let minimumSide: CGFloat = 4

    private var startPoint: CGPoint?
    private var selection: CGRect? {
        didSet { needsDisplay = true }
    }

    override var isFlipped: Bool { true }
    override var acceptsFirstResponder: Bool { true }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func viewDidMoveToWindow() {
        window?.makeFirstResponder(self)
    }

    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .crosshair)
    }

    override func mouseDown(with event: NSEvent) {
        startPoint = convert(event.locationInWindow, from: nil)
        selection = nil
    }

    override func mouseDragged(with event: NSEvent) {
        guard let start = startPoint else { return }
        let current = convert(event.locationInWindow, from: nil)
        selection = CGRect(
            x: min(start.x, current.x),
            y: min(start.y, current.y),
            width: abs(current.x - start.x),
            height: abs(current.y - start.y)
        ).intersection(bounds)
    }

    override func mouseUp(with event: NSEvent) {
        startPoint = nil
        guard let rect = selection, rect.width >= Self.minimumSide, rect.height >= Self.minimumSide else {
            selection = nil
            return
        }
        onSelect?(CaptureRegion(displayID: displayID, rect: rect))
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == Self.escapeKeyCode {
            onCancel?()
        } else {
            super.keyDown(with: event)
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.withAlphaComponent(0.3).setFill()
        bounds.fill()

        guard let selection else { return }

        NSColor.clear.setFill()
        selection.fill(using: .copy)

        NSColor.white.setStroke()
        let border = NSBezierPath(rect: selection)
        border.lineWidth = 1
        border.stroke()

        drawSizeLabel(for: selection)
    }

    private func drawSizeLabel(for rect: CGRect) {
        let text = "\(Int(rect.width)) × \(Int(rect.height))" as NSString
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .medium),
            .foregroundColor: NSColor.white,
        ]
        let size = text.size(withAttributes: attributes)
        let padding: CGFloat = 5
        let badge = CGRect(
            x: rect.minX,
            y: rect.minY >= size.height + padding * 2 + 4 ? rect.minY - size.height - padding * 2 - 4 : rect.maxY + 4,
            width: size.width + padding * 2,
            height: size.height + padding
        )
        NSColor.black.withAlphaComponent(0.7).setFill()
        NSBezierPath(roundedRect: badge, xRadius: 4, yRadius: 4).fill()
        text.draw(at: CGPoint(x: badge.minX + padding, y: badge.minY + padding / 2), withAttributes: attributes)
    }
}
