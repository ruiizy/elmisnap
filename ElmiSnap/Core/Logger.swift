import OSLog

enum Log {
    static let app = Logger(subsystem: "com.elmisnap.app", category: "app")
    static let capture = Logger(subsystem: "com.elmisnap.app", category: "capture")
    static let hotkeys = Logger(subsystem: "com.elmisnap.app", category: "hotkeys")
}
