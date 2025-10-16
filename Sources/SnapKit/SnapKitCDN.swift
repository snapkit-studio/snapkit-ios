import Foundation

/// Configuration for CDN URL building
public struct SnapKitCDNConfig {
    public let baseURL: String
    public let organizationName: String?

    /// Initialize with custom CDN base URL
    public init(baseURL: String) {
        self.baseURL = baseURL
        self.organizationName = nil
    }

    /// Initialize with SnapKit CDN using organization name
    public init(organizationName: String) {
        self.baseURL = "https://cdn.snapkit.studio"
        self.organizationName = organizationName
    }
}

/// Image transformation parameters
public struct SnapKitImageParams {
    public let width: Int?
    public let height: Int?
    public let quality: Int?
    public let format: String?

    public init(
        width: Int? = nil,
        height: Int? = nil,
        quality: Int? = nil,
        format: String? = nil
    ) {
        self.width = width
        self.height = height
        self.quality = quality
        self.format = format
    }
}

/// Pure function CDN URL builder
public enum SnapKitCDN {

    /// Build optimized image URL from source URL
    /// - Parameters:
    ///   - sourceURL: Original image URL or path
    ///   - config: CDN configuration
    ///   - params: Image transformation parameters
    /// - Returns: Optimized CDN URL
    public static func buildURL(
        sourceURL: String,
        config: SnapKitCDNConfig,
        params: SnapKitImageParams = SnapKitImageParams()
    ) -> URL? {
        var components = URLComponents(string: config.baseURL)

        // Build path
        if let orgName = config.organizationName {
            components?.path = "/\(orgName)/\(sourceURL)"
        } else {
            components?.path = "/\(sourceURL)"
        }

        // Build query parameters
        var queryItems: [URLQueryItem] = []

        if let width = params.width {
            queryItems.append(URLQueryItem(name: "w", value: "\(width)"))
        }

        if let height = params.height {
            queryItems.append(URLQueryItem(name: "h", value: "\(height)"))
        }

        if let quality = params.quality {
            queryItems.append(URLQueryItem(name: "q", value: "\(quality)"))
        }

        if let format = params.format {
            queryItems.append(URLQueryItem(name: "f", value: format))
        }

        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }

        return components?.url
    }

    /// Build URL with automatic scale factor (@2x, @3x)
    /// - Parameters:
    ///   - sourceURL: Original image URL or path
    ///   - config: CDN configuration
    ///   - size: Desired image size (will be multiplied by screen scale)
    ///   - quality: Image quality (1-100)
    /// - Returns: Optimized CDN URL with DPR
    public static func buildURL(
        sourceURL: String,
        config: SnapKitCDNConfig,
        size: CGSize,
        quality: Int = 80
    ) -> URL? {
        let scale = Int(UIScreen.main.scale)
        let scaledWidth = Int(size.width) * scale
        let scaledHeight = Int(size.height) * scale

        let params = SnapKitImageParams(
            width: scaledWidth,
            height: scaledHeight,
            quality: quality
        )

        return buildURL(sourceURL: sourceURL, config: config, params: params)
    }
}
