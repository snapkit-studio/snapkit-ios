import SwiftUI

/// SwiftUI view for async image loading with caching
public struct SnapKitAsyncImage<Content: View, Placeholder: View>: View {

    private let url: URL?
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder
    private let loader: SnapKitImageLoader

    @State private var loadedImage: UIImage?
    @State private var isLoading = false
    @State private var error: Error?

    /// Initialize with URL and custom content/placeholder views
    /// - Parameters:
    ///   - url: Image URL
    ///   - loader: Image loader (defaults to shared)
    ///   - content: View builder for loaded image
    ///   - placeholder: View builder for placeholder
    public init(
        url: URL?,
        loader: SnapKitImageLoader = .shared,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.loader = loader
        self.content = content
        self.placeholder = placeholder
    }

    public var body: some View {
        Group {
            if let loadedImage = loadedImage {
                content(Image(uiImage: loadedImage))
            } else {
                placeholder()
            }
        }
        .task(id: url) {
            await loadImage()
        }
    }

    private func loadImage() async {
        guard let url = url else {
            loadedImage = nil
            return
        }

        isLoading = true
        error = nil

        do {
            let image = try await loader.loadImage(from: url)
            loadedImage = image
        } catch {
            self.error = error
            loadedImage = nil
        }

        isLoading = false
    }
}

// MARK: - Convenience Initializers

extension SnapKitAsyncImage where Content == Image {
    /// Initialize with URL and default image rendering
    /// - Parameters:
    ///   - url: Image URL
    ///   - loader: Image loader (defaults to shared)
    ///   - placeholder: Placeholder view
    public init(
        url: URL?,
        loader: SnapKitImageLoader = .shared,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.init(
            url: url,
            loader: loader,
            content: { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            },
            placeholder: placeholder
        )
    }
}

extension SnapKitAsyncImage where Placeholder == Color {
    /// Initialize with URL and color placeholder
    /// - Parameters:
    ///   - url: Image URL
    ///   - loader: Image loader (defaults to shared)
    ///   - content: View builder for loaded image
    public init(
        url: URL?,
        loader: SnapKitImageLoader = .shared,
        @ViewBuilder content: @escaping (Image) -> Content
    ) {
        self.init(
            url: url,
            loader: loader,
            content: content,
            placeholder: { Color.gray.opacity(0.2) }
        )
    }
}

extension SnapKitAsyncImage where Content == Image, Placeholder == Color {
    /// Initialize with URL only, using default rendering and placeholder
    /// - Parameters:
    ///   - url: Image URL
    ///   - loader: Image loader (defaults to shared)
    public init(
        url: URL?,
        loader: SnapKitImageLoader = .shared
    ) {
        self.init(
            url: url,
            loader: loader,
            content: { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            },
            placeholder: { Color.gray.opacity(0.2) }
        )
    }

    /// Initialize with URL string only
    /// - Parameters:
    ///   - urlString: Image URL string
    ///   - loader: Image loader (defaults to shared)
    public init(
        urlString: String?,
        loader: SnapKitImageLoader = .shared
    ) {
        let url = urlString.flatMap { URL(string: $0) }
        self.init(url: url, loader: loader)
    }
}
