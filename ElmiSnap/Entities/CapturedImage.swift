import CoreGraphics
import Foundation

struct CapturedImage: @unchecked Sendable {
    let cgImage: CGImage
    let capturedAt: Date
    /// Pixels per point of the display the image was captured from.
    let scale: CGFloat

    var pixelSize: CGSize {
        CGSize(width: cgImage.width, height: cgImage.height)
    }

    var pointSize: CGSize {
        CGSize(width: pixelSize.width / scale, height: pixelSize.height / scale)
    }
}
