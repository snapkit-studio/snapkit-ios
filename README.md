# snapkit-image

[![](https://img.shields.io/badge/SwiftPM-compatible-brightgreen)](https://swift.org/package-manager/)
![](https://img.shields.io/badge/Swift-6.0%2B-orange)
![](https://img.shields.io/badge/Platforms-iOS%2013%2B%20%7C%20macOS%2012%2B-lightgrey)

A Swift package for image transformation and optimization.

## Summary

`snapkit-image` is a Swift library designed to make it easy to use the
[`Snapkit`](https://www.snapkit.studio/docs) service.

It provides a clean, chainable API for configuring image transformations—such as resizing, format conversion, blur, rotation, and extraction—and converts them into URL query parameters that can be directly applied to image URLs.

## Features

- Chainable API for image transformation configuration
- Optimized for use with URL-based image delivery services

## Installation

`snapkit-image` supports **Swift Package Manager** only.

### Using Xcode

1. Open your project in Xcode
2. Go to **File → Add Packages…**
3. Enter the package URL:

   https://github.com/your-org/snapkit-ios

4. Select the version rule and add the package to your target

### Using Package.swift

Add the dependency to your `Package.swift` file:

    dependencies: [
        .package(
            url: "https://github.com/your-org/snapkit-ios",
            from: "1.0.0"
        )
    ]

Then add `snapkit-image` to your target dependencies:

    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "snapkit_image", package: "snapkit-image")
        ]
    )

## Usage

### Basic Example

```swift
import snapkit_image

// MARK: - Transform Options

// Creates a set of image transformation options.
// Each option is applied in a chainable manner and later converted into a URL query string.
let transform = TransformOptions()
    .setWidth(400)
    .setHeight(300)
    .setFit(.cover)
    .setFormat(.jpeg)
    .setBlur(15)
    .setGrayscale(true)
    .setRotation(90)
    .setFlip(true)
    .setQuality(80)

// Builds a transform query string from the configured options.
let query = transform.buildTransformString()
// Result:
// "w:400,h:300,fit:cover,format:jpeg,blur:15,grayscale,rotation:90,flip,quality:80"


// MARK: - URL Builder

// Generates a transformed image URL by appending transform parameters to a base URL.
let baseURL = URL(string: "https://example.com/sample.jpg")!

let finalURL = TransformQueryBuilder(url: baseURL)
    .width(400)
    .height(300)
    .fit(.cover)
    .format(.webp)
    .blur(20)
    .grayscale()
    .flip()
    .quality(90)
    .currentURL()

// Result:
// https://example.com/sample.jpg?transform=w:400,h:300,fit:cover,format:webp,blur:20,grayscale,flip,quality:90
