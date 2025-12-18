//
//  TransformQueryBuilder.swift
//  snapkit-image
//
//  Created by 김재한 on 12/17/25.
//

import Foundation

/// Builds transform query strings and URLs from TransformOptions values
public class TransformQueryBuilder {
    
    private let url: URL?
    private let options = TransformOptions()
    
    public init(url: URL?) {
        self.url = url
    }

    /// Builds only the transform value (without the leading "?transform=") for use in query items.
    private func buildTransformValue(options: TransformOptions) -> String {
        let transformString = options.buildTransformString()
        let prefix = "?transform="
        return transformString.hasPrefix(prefix) ? String(transformString.dropFirst(prefix.count)) : transformString
    }

    /// Builds a URL by appending the transform query (name: "transform") to the given base URL.
    public func buildTransformURL(options: TransformOptions) -> URL? {
        guard let url else { return nil }
        let value = buildTransformValue(options: options)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        var items = components?.queryItems ?? []
        items.removeAll { $0.name == "transform" }
        items.append(URLQueryItem(name: "transform", value: value))
        components?.queryItems = items
        return components?.url
    }
}

extension TransformQueryBuilder {
    /// Sets width and returns self for chaining
    @discardableResult
    public func width(_ value: Int) -> TransformQueryBuilder {
        options.setWidth(value)
        return self
    }

    /// Sets height and returns self for chaining
    @discardableResult
    public func height(_ value: Int) -> TransformQueryBuilder {
        options.setHeight(value)
        return self
    }

    /// Sets fit and returns self for chaining
    @discardableResult
    public func fit(_ value: TransformOptions.Fit) -> TransformQueryBuilder {
        options.setFit(value)
        return self
    }

    /// Sets format and returns self for chaining
    @discardableResult
    public func format(_ value: TransformOptions.Format) -> TransformQueryBuilder {
        options.setFormat(value)
        return self
    }

    /// Sets rotation and returns self for chaining
    @discardableResult
    public func rotation(_ value: Int) -> TransformQueryBuilder {
        options.setRotation(value)
        return self
    }

    /// Sets blur and returns self for chaining
    @discardableResult
    public func blur(_ value: Int) -> TransformQueryBuilder {
        options.setBlur(value)
        return self
    }

    /// Sets grayscale and returns self for chaining
    @discardableResult
    public func grayscale(_ value: Bool = true) -> TransformQueryBuilder {
        options.setGrayscale(value)
        return self
    }

    /// Sets flip and returns self for chaining
    @discardableResult
    public func flip(_ value: Bool = true) -> TransformQueryBuilder {
        options.setFlip(value)
        return self
    }

    /// Sets flop and returns self for chaining
    @discardableResult
    public func flop(_ value: Bool = true) -> TransformQueryBuilder {
        options.setFlop(value)
        return self
    }

    /// Sets extract rect and returns self for chaining
    @discardableResult
    public func extract(x: Int, y: Int, width: Int, height: Int) -> TransformQueryBuilder {
        options.setExtract(x: x, y: y, width: width, height: height)
        return self
    }

    /// Sets device pixel ratio and returns self for chaining
    @discardableResult
    public func dpr(_ value: Double) -> TransformQueryBuilder {
        options.setDPR(value)
        return self
    }

    /// Sets quality and returns self for chaining
    @discardableResult
    public func quality(_ value: Int) -> TransformQueryBuilder {
        options.setQuality(value)
        return self
    }

    /// Builds only the transform value string (without the leading "?transform=")
    public func currentValue() -> String {
        buildTransformValue(options: options)
    }

    /// Builds the final URL with the accumulated options
    public func currentURL() -> URL? {
        buildTransformURL(options: options)
    }
}
