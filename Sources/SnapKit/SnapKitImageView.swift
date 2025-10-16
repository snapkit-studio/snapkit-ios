import UIKit

/// UIImageView subclass with built-in image loading and caching
open class SnapKitImageView: UIImageView {

    private var currentTask: Task<Void, Never>?
    private let loader: SnapKitImageLoader

    /// Placeholder image shown while loading
    public var placeholderImage: UIImage? {
        didSet {
            if image == nil {
                image = placeholderImage
            }
        }
    }

    /// Error image shown when loading fails
    public var errorImage: UIImage?

    public init(loader: SnapKitImageLoader = .shared) {
        self.loader = loader
        super.init(frame: .zero)
        setup()
    }

    public override init(frame: CGRect) {
        self.loader = .shared
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        self.loader = .shared
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        contentMode = .scaleAspectFill
        clipsToBounds = true
    }

    /// Load image from URL
    /// - Parameters:
    ///   - url: Image URL
    ///   - placeholder: Optional placeholder image
    public func load(
        url: URL?,
        placeholder: UIImage? = nil
    ) {
        // Cancel previous task
        currentTask?.cancel()

        // Set placeholder
        if let placeholder = placeholder ?? placeholderImage {
            image = placeholder
        }

        guard let url = url else {
            image = errorImage ?? placeholderImage
            return
        }

        currentTask = Task {
            do {
                let loadedImage = try await loader.loadImage(from: url)

                // Check if task was cancelled
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    self.image = loadedImage
                }
            } catch {
                // Check if task was cancelled
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    self.image = self.errorImage ?? self.placeholderImage
                }
            }
        }
    }

    /// Load image from URL string
    /// - Parameters:
    ///   - urlString: Image URL string
    ///   - placeholder: Optional placeholder image
    public func load(
        urlString: String?,
        placeholder: UIImage? = nil
    ) {
        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            image = errorImage ?? placeholderImage
            return
        }

        load(url: url, placeholder: placeholder)
    }

    /// Cancel current image loading task
    public func cancelLoading() {
        currentTask?.cancel()
        currentTask = nil
    }

    deinit {
        cancelLoading()
    }
}
