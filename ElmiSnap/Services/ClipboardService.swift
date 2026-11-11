import AppKit

@MainActor
protocol ClipboardService: AnyObject {
    func copy(_ image: CapturedImage)
}

@MainActor
final class PasteboardClipboardService: ClipboardService {
    func copy(_ image: CapturedImage) {
        let nsImage = NSImage(cgImage: image.cgImage, size: image.pointSize)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([nsImage])
    }
}
