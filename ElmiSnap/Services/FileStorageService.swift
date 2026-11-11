import Foundation
import ImageIO

enum FileStorageError: LocalizedError {
    case cannotCreateDestination
    case cannotWriteImage

    var errorDescription: String? {
        switch self {
        case .cannotCreateDestination: "Could not create the image file."
        case .cannotWriteImage: "Could not write the image data."
        }
    }
}

protocol FileStorageService: Sendable {
    func write(_ image: CapturedImage, format: ImageFormat, to url: URL) throws
    func defaultFileName(format: ImageFormat, date: Date) -> String
}

struct ImageIOFileStorageService: FileStorageService {
    func write(_ image: CapturedImage, format: ImageFormat, to url: URL) throws {
        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL, format.utType.identifier as CFString, 1, nil
        ) else {
            throw FileStorageError.cannotCreateDestination
        }
        let properties: [CFString: Any] = [kCGImageDestinationLossyCompressionQuality: 0.9]
        CGImageDestinationAddImage(destination, image.cgImage, properties as CFDictionary)
        guard CGImageDestinationFinalize(destination) else {
            throw FileStorageError.cannotWriteImage
        }
    }

    func defaultFileName(format: ImageFormat, date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd 'at' HH.mm.ss"
        return "ElmiSnap \(formatter.string(from: date)).\(format.fileExtension)"
    }
}
