import XCTest
@testable import SnapKit

final class SnapKitCDNTests: XCTestCase {

    // MARK: - Custom CDN Tests

    func testBuildURL_WithCustomCDN_BasicURL() {
        let config = SnapKitCDNConfig(baseURL: "https://cdn.example.com")
        let url = SnapKitCDN.buildURL(
            sourceURL: "images/photo.jpg",
            config: config
        )

        XCTAssertNotNil(url)
        XCTAssertEqual(url?.absoluteString, "https://cdn.example.com/images/photo.jpg")
    }

    func testBuildURL_WithCustomCDN_WithWidth() {
        let config = SnapKitCDNConfig(baseURL: "https://cdn.example.com")
        let params = SnapKitImageParams(width: 800)
        let url = SnapKitCDN.buildURL(
            sourceURL: "images/photo.jpg",
            config: config,
            params: params
        )

        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("w=800") ?? false)
    }

    func testBuildURL_WithCustomCDN_WithHeight() {
        let config = SnapKitCDNConfig(baseURL: "https://cdn.example.com")
        let params = SnapKitImageParams(height: 600)
        let url = SnapKitCDN.buildURL(
            sourceURL: "images/photo.jpg",
            config: config,
            params: params
        )

        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("h=600") ?? false)
    }

    func testBuildURL_WithCustomCDN_WithQuality() {
        let config = SnapKitCDNConfig(baseURL: "https://cdn.example.com")
        let params = SnapKitImageParams(quality: 80)
        let url = SnapKitCDN.buildURL(
            sourceURL: "images/photo.jpg",
            config: config,
            params: params
        )

        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("q=80") ?? false)
    }

    func testBuildURL_WithCustomCDN_WithFormat() {
        let config = SnapKitCDNConfig(baseURL: "https://cdn.example.com")
        let params = SnapKitImageParams(format: "webp")
        let url = SnapKitCDN.buildURL(
            sourceURL: "images/photo.jpg",
            config: config,
            params: params
        )

        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("f=webp") ?? false)
    }

    func testBuildURL_WithCustomCDN_AllParameters() {
        let config = SnapKitCDNConfig(baseURL: "https://cdn.example.com")
        let params = SnapKitImageParams(
            width: 800,
            height: 600,
            quality: 80,
            format: "webp"
        )
        let url = SnapKitCDN.buildURL(
            sourceURL: "images/photo.jpg",
            config: config,
            params: params
        )

        XCTAssertNotNil(url)
        let urlString = url?.absoluteString ?? ""
        XCTAssertTrue(urlString.contains("w=800"))
        XCTAssertTrue(urlString.contains("h=600"))
        XCTAssertTrue(urlString.contains("q=80"))
        XCTAssertTrue(urlString.contains("f=webp"))
    }

    // MARK: - SnapKit CDN Tests

    func testBuildURL_WithSnapKitCDN_BasicURL() {
        let config = SnapKitCDNConfig(organizationName: "myorg")
        let url = SnapKitCDN.buildURL(
            sourceURL: "images/photo.jpg",
            config: config
        )

        XCTAssertNotNil(url)
        XCTAssertEqual(url?.absoluteString, "https://cdn.snapkit.studio/myorg/images/photo.jpg")
    }

    func testBuildURL_WithSnapKitCDN_WithParameters() {
        let config = SnapKitCDNConfig(organizationName: "myorg")
        let params = SnapKitImageParams(width: 800, quality: 80)
        let url = SnapKitCDN.buildURL(
            sourceURL: "images/photo.jpg",
            config: config,
            params: params
        )

        XCTAssertNotNil(url)
        let urlString = url?.absoluteString ?? ""
        XCTAssertTrue(urlString.contains("myorg/images/photo.jpg"))
        XCTAssertTrue(urlString.contains("w=800"))
        XCTAssertTrue(urlString.contains("q=80"))
    }

    // MARK: - Edge Cases

    func testBuildURL_EmptySourceURL() {
        let config = SnapKitCDNConfig(baseURL: "https://cdn.example.com")
        let url = SnapKitCDN.buildURL(
            sourceURL: "",
            config: config
        )

        XCTAssertNotNil(url)
        XCTAssertEqual(url?.path, "/")
    }

    func testBuildURL_NoParameters() {
        let config = SnapKitCDNConfig(baseURL: "https://cdn.example.com")
        let params = SnapKitImageParams()
        let url = SnapKitCDN.buildURL(
            sourceURL: "image.jpg",
            config: config,
            params: params
        )

        XCTAssertNotNil(url)
        XCTAssertNil(url?.query)
    }

    func testBuildURL_SpecialCharactersInPath() {
        let config = SnapKitCDNConfig(baseURL: "https://cdn.example.com")
        let url = SnapKitCDN.buildURL(
            sourceURL: "images/my photo.jpg",
            config: config
        )

        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("my%20photo.jpg") ?? false)
    }

    // MARK: - Size-based URL Building

    func testBuildURL_WithSize_Scale1x() {
        // Mock UIScreen.main.scale = 1.0 (testing without actual UIScreen mock)
        let config = SnapKitCDNConfig(baseURL: "https://cdn.example.com")
        let size = CGSize(width: 100, height: 100)

        let url = SnapKitCDN.buildURL(
            sourceURL: "image.jpg",
            config: config,
            size: size,
            quality: 80
        )

        XCTAssertNotNil(url)
        let urlString = url?.absoluteString ?? ""
        XCTAssertTrue(urlString.contains("q=80"))
        // Width/height will be multiplied by UIScreen.main.scale
        // On test environment, scale might vary, so we just check URL exists
    }

    func testBuildURL_WithSize_CustomQuality() {
        let config = SnapKitCDNConfig(baseURL: "https://cdn.example.com")
        let size = CGSize(width: 200, height: 150)

        let url = SnapKitCDN.buildURL(
            sourceURL: "image.jpg",
            config: config,
            size: size,
            quality: 60
        )

        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("q=60") ?? false)
    }

    // MARK: - Configuration Tests

    func testCDNConfig_CustomBaseURL() {
        let config = SnapKitCDNConfig(baseURL: "https://custom.cdn.com")

        XCTAssertEqual(config.baseURL, "https://custom.cdn.com")
        XCTAssertNil(config.organizationName)
    }

    func testCDNConfig_SnapKitCDN() {
        let config = SnapKitCDNConfig(organizationName: "testorg")

        XCTAssertEqual(config.baseURL, "https://cdn.snapkit.studio")
        XCTAssertEqual(config.organizationName, "testorg")
    }

    // MARK: - Image Params Tests

    func testImageParams_DefaultInit() {
        let params = SnapKitImageParams()

        XCTAssertNil(params.width)
        XCTAssertNil(params.height)
        XCTAssertNil(params.quality)
        XCTAssertNil(params.format)
    }

    func testImageParams_PartialInit() {
        let params = SnapKitImageParams(width: 800, quality: 80)

        XCTAssertEqual(params.width, 800)
        XCTAssertNil(params.height)
        XCTAssertEqual(params.quality, 80)
        XCTAssertNil(params.format)
    }

    func testImageParams_FullInit() {
        let params = SnapKitImageParams(
            width: 800,
            height: 600,
            quality: 80,
            format: "webp"
        )

        XCTAssertEqual(params.width, 800)
        XCTAssertEqual(params.height, 600)
        XCTAssertEqual(params.quality, 80)
        XCTAssertEqual(params.format, "webp")
    }
}
