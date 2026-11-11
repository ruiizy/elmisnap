import CoreGraphics

/// A rectangle on one display.
///
/// `rect` is in points, relative to the display, with the origin at the
/// top-left (the coordinate space ScreenCaptureKit's `sourceRect` expects).
struct CaptureRegion: Sendable, Equatable {
    let displayID: CGDirectDisplayID
    let rect: CGRect
}
