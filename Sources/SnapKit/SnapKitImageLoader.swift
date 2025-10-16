import UIKit

/// Error types for image loading
public enum SnapKitError: Error {
    case invalidURL
    case downloadFailed(Error)
    case invalidImageData
}

/// Async image loader with caching support
public final class SnapKitImageLoader {

    /// Shared singleton instance
    public static let shared = SnapKitImageLoader()

    private let session: URLSession
    private let cache: SnapKitCache

    public init(
        session: URLSession = .shared,
        cache: SnapKitCache = .shared
    ) {
        self.session = session
        self.cache = cache
    }

    /// Load image from URL with caching
    /// - Parameter url: Image URL
    /// - Returns: Loaded UIImage
    public func loadImage(from url: URL) async throws -> UIImage {
        let cacheKey = url.absoluteString

        // Check cache first
        if let cachedImage = cache.image(forKey: cacheKey) {
            return cachedImage
        }

        // Download image
        let (data, response) = try await session.data(from: url)

        // Validate response
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw SnapKitError.downloadFailed(
                NSError(domain: "SnapKit", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Invalid HTTP response"
                ])
            )
        }

        // Create image from data
        guard let image = UIImage(data: data) else {
            throw SnapKitError.invalidImageData
        }

        // Cache the image
        cache.setImage(image, forKey: cacheKey)

        return image
    }

    /// Load image from URL string
    /// - Parameter urlString: Image URL string
    /// - Returns: Loaded UIImage
    public func loadImage(from urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw SnapKitError.invalidURL
        }
        return try await loadImage(from: url)
    }

    /// Cancel all pending downloads
    public func cancelAllTasks() {
        session.getAllTasks { tasks in
            tasks.forEach { $0.cancel() }
        }
    }
}
