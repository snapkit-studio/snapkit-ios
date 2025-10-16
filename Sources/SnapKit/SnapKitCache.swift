import UIKit

/// Memory cache for loaded images
public final class SnapKitCache {

    /// Shared singleton instance
    public static let shared = SnapKitCache()

    private let cache = NSCache<NSString, UIImage>()

    private init() {
        // Configure cache limits
        cache.countLimit = 100 // Maximum 100 images
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB limit

        // Clear cache on memory warning
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearCache),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    /// Store image in cache
    /// - Parameters:
    ///   - image: Image to cache
    ///   - key: Cache key (typically URL string)
    public func setImage(_ image: UIImage, forKey key: String) {
        let cost = Int(image.size.width * image.size.height * image.scale * image.scale)
        cache.setObject(image, forKey: key as NSString, cost: cost)
    }

    /// Retrieve image from cache
    /// - Parameter key: Cache key
    /// - Returns: Cached image if available
    public func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }

    /// Remove image from cache
    /// - Parameter key: Cache key
    public func removeImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }

    /// Clear all cached images
    @objc public func clearCache() {
        cache.removeAllObjects()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
