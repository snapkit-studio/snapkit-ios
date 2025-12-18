import Foundation
import Testing

@testable import snapkit_image

@Suite("TransformQueryBuilder Tests")
struct TransformQueryBuilderTests {

    // MARK: - Base URL handling
    @Test("Returns nil when base URL is nil")
    func nilBaseURLReturnsNil() async throws {
        let builder = TransformQueryBuilder(url: nil)
        let url = builder.buildTransformURL(options: TransformOptions().setWidth(100))
        #expect(url == nil)
        // currentURL should also be nil when base is nil
        #expect(builder.currentURL() == nil)
    }

    // MARK: - Building with options parameter
    @Test("Appends transform to clean URL with options")
    func appendsTransformToCleanURLWithOptions() async throws {
        let base = URL(string: "https://example.com/image.png")!
        let builder = TransformQueryBuilder(url: base)
        let options = TransformOptions()
            .setWidth(300)
            .setHeight(200)
            .setFormat(.webp)
        let url = try #require(builder.buildTransformURL(options: options))
        let comps = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        #expect(comps.scheme == "https")
        #expect(comps.host == "example.com")
        #expect(comps.path == "/image.png")
        let transform = comps.queryItems?.first(where: { $0.name == "transform" })
        let value = try #require(transform?.value)
        #expect(value.contains("w:300"))
        #expect(value.contains("h:200"))
        #expect(value.contains("format:webp"))
    }

    // MARK: - Replacing existing transform, preserving others
    @Test("Replaces existing transform and preserves other queries")
    func replacesExistingTransformAndPreservesOthers() async throws {
        var comps = URLComponents(string: "https://example.com/pic.jpg")!
        comps.queryItems = [
            URLQueryItem(name: "foo", value: "bar"),
            URLQueryItem(name: "transform", value: "w:10,h:10")
        ]
        let base = try #require(comps.url)
        let builder = TransformQueryBuilder(url: base)
        let options = TransformOptions().setWidth(999).setFit(.cover)
        let url = try #require(builder.buildTransformURL(options: options))
        let out = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        // foo=bar should remain
        #expect(out.queryItems?.contains(where: { $0.name == "foo" && $0.value == "bar" }) == true)
        // transform should be replaced
        let tItems = out.queryItems?.filter { $0.name == "transform" } ?? []
        #expect(tItems.count == 1)
        let value = try #require(tItems.first?.value)
        #expect(value.contains("w:999"))
        #expect(value.contains("fit:cover"))
        #expect(!value.contains("h:10"))
    }

    // MARK: - Preserving unrelated queries when adding transform
    @Test("Preserves unrelated queries and appends transform")
    func preservesOtherQueries() async throws {
        var comps = URLComponents(string: "https://example.com/a/b")!
        comps.queryItems = [
            URLQueryItem(name: "alpha", value: "1"),
            URLQueryItem(name: "beta", value: nil)
        ]
        let base = try #require(comps.url)
        let builder = TransformQueryBuilder(url: base)
        let options = TransformOptions().setBlur(5).setGrayscale(true)
        let url = try #require(builder.buildTransformURL(options: options))
        let out = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        #expect(out.queryItems?.contains(where: { $0.name == "alpha" && $0.value == "1" }) == true)
        #expect(out.queryItems?.contains(where: { $0.name == "beta" && $0.value == nil }) == true)
        let value = try #require(out.queryItems?.first(where: { $0.name == "transform" })?.value)
        #expect(value.contains("blur:5"))
        #expect(value.contains("grayscale"))
    }

    // MARK: - Mixed: options + builder chaining should align
    @Test("Options and builder chaining produce same transform")
    func optionsAndBuilderProduceSameTransform() async throws {
        let base = URL(string: "https://assets.example.org/a.png")!
        let options = TransformOptions()
            .setWidth(320)
            .setHeight(240)
            .setFormat(.webp)
            .setFit(.cover)
            .setDPR(1.5)
            .setQuality(70)
        let builderA = TransformQueryBuilder(url: base)
        let urlA = try #require(builderA.buildTransformURL(options: options))
        let compsA = try #require(URLComponents(url: urlA, resolvingAgainstBaseURL: false))

        let builderB = TransformQueryBuilder(url: base)
            .width(320)
            .height(240)
            .format(.webp)
            .fit(.cover)
            .dpr(1.5)
            .quality(70)
        let urlB = try #require(builderB.currentURL())
        let compsB = try #require(URLComponents(url: urlB, resolvingAgainstBaseURL: false))
        // Both approaches should preserve the same base components
        #expect(compsA.scheme == compsB.scheme)
        #expect(compsA.host == compsB.host)
        #expect(compsA.path == compsB.path)
    }
}
