# SnapKit-iOS

Next-generation image optimization for iOS applications with automatic caching and CDN integration.

## Features

- 🚀 **Async Image Loading** - Built with Swift's modern async/await
- 💾 **Automatic Caching** - Memory cache with intelligent size management
- 🎨 **UIKit & SwiftUI Support** - First-class components for both frameworks
- 🌐 **CDN Integration** - Support for SnapKit CDN and custom CDN providers
- 📦 **Zero Dependencies** - Lightweight implementation using Foundation only
- ⚡ **Performance Optimized** - Automatic DPR scaling and memory management

## Requirements

- iOS 13.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add SnapKit to your project via Xcode:

1. File > Add Package Dependencies
2. Enter: `https://github.com/YOUR-USERNAME/snapkit-ios`
3. Select version and add to your target

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/YOUR-USERNAME/snapkit-ios", from: "1.0.0")
]
```

## Usage

### SwiftUI

#### Basic Usage

```swift
import SwiftUI
import SnapKit

struct ContentView: View {
    var body: some View {
        SnapKitAsyncImage(
            url: URL(string: "https://example.com/image.jpg")
        )
        .frame(width: 300, height: 200)
        .cornerRadius(12)
    }
}
```

#### With Custom Placeholder

```swift
SnapKitAsyncImage(url: imageURL) {
    ProgressView()
}
.frame(width: 300, height: 200)
```

#### With Custom Content

```swift
SnapKitAsyncImage(url: imageURL) { image in
    image
        .resizable()
        .aspectRatio(contentMode: .fit)
        .clipShape(Circle())
} placeholder: {
    Color.gray.opacity(0.2)
}
.frame(width: 100, height: 100)
```

### UIKit

#### Basic Usage

```swift
import UIKit
import SnapKit

class ViewController: UIViewController {
    let imageView = SnapKitImageView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(imageView)
        imageView.frame = CGRect(x: 0, y: 0, width: 300, height: 200)

        imageView.load(
            url: URL(string: "https://example.com/image.jpg")
        )
    }
}
```

#### With Placeholder

```swift
imageView.placeholderImage = UIImage(systemName: "photo")
imageView.load(url: imageURL)
```

#### With Error Handling

```swift
imageView.placeholderImage = UIImage(systemName: "photo")
imageView.errorImage = UIImage(systemName: "exclamationmark.triangle")
imageView.load(url: imageURL)
```

### CDN Integration

#### SnapKit CDN

```swift
import SnapKit

// Configure SnapKit CDN
let config = SnapKitCDNConfig(organizationName: "myorg")

// Build optimized URL
let params = SnapKitImageParams(
    width: 800,
    height: 600,
    quality: 80,
    format: "webp"
)

if let optimizedURL = SnapKitCDN.buildURL(
    sourceURL: "images/photo.jpg",
    config: config,
    params: params
) {
    imageView.load(url: optimizedURL)
}

// Result: https://cdn.snapkit.studio/myorg/images/photo.jpg?w=800&h=600&q=80&f=webp
```

#### Custom CDN

```swift
// Configure custom CDN
let config = SnapKitCDNConfig(baseURL: "https://cdn.example.com")

let params = SnapKitImageParams(width: 800, quality: 80)

if let optimizedURL = SnapKitCDN.buildURL(
    sourceURL: "images/photo.jpg",
    config: config,
    params: params
) {
    imageView.load(url: optimizedURL)
}

// Result: https://cdn.example.com/images/photo.jpg?w=800&q=80
```

#### Automatic DPR Scaling

```swift
// Automatically applies @2x/@3x based on device screen
let config = SnapKitCDNConfig(organizationName: "myorg")

if let url = SnapKitCDN.buildURL(
    sourceURL: "photo.jpg",
    config: config,
    size: CGSize(width: 200, height: 150),
    quality: 80
) {
    imageView.load(url: url)
}

// On @3x device: w=600, h=450
// On @2x device: w=400, h=300
```

### Cache Management

```swift
import SnapKit

// Access shared cache
let cache = SnapKitCache.shared

// Clear all cached images
cache.clearCache()

// Remove specific image
cache.removeImage(forKey: "https://example.com/image.jpg")

// Manually cache image
cache.setImage(myImage, forKey: "custom-key")

// Retrieve cached image
if let cachedImage = cache.image(forKey: "custom-key") {
    // Use cached image
}
```

## Architecture

### Components

- **SnapKitCDN** - Pure function URL builder for CDN integration
- **SnapKitCache** - NSCache-based memory cache with automatic management
- **SnapKitImageLoader** - Async/await URLSession image loader
- **SnapKitImageView** - UIKit component with built-in loading states
- **SnapKitAsyncImage** - SwiftUI component with declarative API

### How It Works

1. **URL Building** - SnapKitCDN generates optimized CDN URLs with parameters
2. **Cache Check** - Loader checks memory cache first
3. **Network Request** - If not cached, downloads via URLSession
4. **Caching** - Automatically caches downloaded images
5. **Display** - Updates UI on main thread

### Memory Management

- Automatic cache eviction on memory warnings
- NSCache handles memory pressure automatically
- 100 image count limit (configurable)
- 50MB total size limit (configurable)

## Testing

Run tests via Xcode:

```bash
swift test
```

Or via command line:

```bash
xcodebuild test \
    -scheme SnapKit \
    -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Performance

- **Cache Hit**: < 1ms (memory access)
- **Cache Miss**: Network-dependent
- **Memory Usage**: ~500KB per 100 images (varies by size)
- **Thread Safety**: All operations are thread-safe

## Roadmap

- [ ] Disk caching support
- [ ] Network quality detection
- [ ] Progressive image loading
- [ ] Image preprocessing pipeline
- [ ] Prefetch support
- [ ] Analytics integration

## License

MIT License - see LICENSE file for details

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Credits

Inspired by [SnapKit-JS](https://github.com/snapkit-studio/snapkit-js)