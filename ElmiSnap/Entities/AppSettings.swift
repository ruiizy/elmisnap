import Foundation
import UniformTypeIdentifiers

enum ImageFormat: String, Sendable, CaseIterable {
    case png
    case jpeg

    var displayName: String {
        switch self {
        case .png: "PNG"
        case .jpeg: "JPEG"
        }
    }

    var fileExtension: String {
        switch self {
        case .png: "png"
        case .jpeg: "jpg"
        }
    }

    var utType: UTType {
        switch self {
        case .png: .png
        case .jpeg: .jpeg
        }
    }
}

struct AppSettings: Equatable, Sendable {
    var imageFormat: ImageFormat = .png
    var copyToClipboard = true
    var showPreview = true
    /// When set, every capture is also written here automatically.
    var saveDirectory: URL?
}
