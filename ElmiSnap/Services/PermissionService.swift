import CoreGraphics

protocol PermissionService: Sendable {
    var hasScreenRecordingAccess: Bool { get }
    /// Triggers the system prompt the first time; returns the current state.
    @discardableResult
    func requestScreenRecordingAccess() -> Bool
}

struct SystemPermissionService: PermissionService {
    var hasScreenRecordingAccess: Bool {
        CGPreflightScreenCaptureAccess()
    }

    @discardableResult
    func requestScreenRecordingAccess() -> Bool {
        CGRequestScreenCaptureAccess()
    }
}
