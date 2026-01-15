//
//  ImageDownloader.swift
//  Data
//
//  Created by 김재한 on 12/15/25.
//

import Foundation
import os
import RxSwift
import UIKit

public struct DisplayInfo {
    public let memory: Int
    public let time: Double
    public let count: Int
    
    public init(memory: Int, time: Double, count: Int) {
        self.memory = memory
        self.time = time
        self.count = count
    }
}

@MainActor
public class ImageDownloader {
    
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "ImageDownloader", category: "ImageDownload")
    
    private var totalMemory: Int = 0
    private var maxElapsedMS: Double = 0
    private var totalCount: Int = 0
    private var downloadedResources: [String: String] = [:] // URL -> eTag 매핑
    
    public var displayInfo = PublishSubject<DisplayInfo>()
    
    public init() {
        
    }
    
    public func downloadImage(from url: URL?) async throws -> UIImage {
        guard let url else {
            let error = NSError(domain: "ImageDownloader", code: 0, userInfo: [NSLocalizedDescriptionKey: "URL is nil"])
            Self.logger.error("Image download failed for nil URL")
            throw error
        }

        let startTime = Date()
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            let elapsedMS = Date().timeIntervalSince(startTime) * 1000
            Self.logger.error("Image download failed for \(url.absoluteString, privacy: .public) after \(elapsedMS, format: .fixed(precision: 2)) ms: \(error.localizedDescription, privacy: .public)")
            throw error
        }

        let elapsedMS = Date().timeIntervalSince(startTime) * 1000

        guard let http = response as? HTTPURLResponse else {
            Self.logger.error("Image download failed for \(url.absoluteString, privacy: .public) after \(elapsedMS, format: .fixed(precision: 2)) ms: missing HTTPURLResponse")
            throw URLError(.badServerResponse)
        }

        guard (200..<300).contains(http.statusCode) else {
            Self.logger.error("Image download failed for \(url.absoluteString, privacy: .public) after \(elapsedMS, format: .fixed(precision: 2)) ms: status \(http.statusCode)")
            throw URLError(.badServerResponse)
        }

        guard !data.isEmpty else {
            Self.logger.error("Image download failed for \(url.absoluteString, privacy: .public) after \(elapsedMS, format: .fixed(precision: 2)) ms: zero-byte resource")
            throw URLError(.zeroByteResource)
        }

        // Convert to UIImage
        guard let image = UIImage(data: data) else {
            Self.logger.error("Image download failed for \(url.absoluteString, privacy: .public): invalid image data")
            throw URLError(.cannotDecodeContentData)
        }

        // eTag 추출 (value(forHTTPHeaderField:)는 대소문자 구분 없음)
        // eTag 값에서 따옴표 제거 (예: "abc123" -> abc123)
        let rawETag = http.value(forHTTPHeaderField: "ETag") ?? ""
        let eTag = rawETag.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        let urlString = url.absoluteString
        
        // 중복 다운로드 확인
        // 1. URL이 이미 다운로드한 리소스 목록에 있는지 확인
        // 2. eTag가 있는 경우: 저장된 eTag와 현재 eTag 비교
        // 3. eTag가 없는 경우: URL만으로 중복 확인 (이미 다운로드한 URL인지 확인)
        let savedETag = self.downloadedResources[urlString]
        let isDuplicate: Bool
        if let saved = savedETag {
            if !eTag.isEmpty {
                // eTag가 있는 경우: eTag 비교
                isDuplicate = (saved == eTag)
            } else {
                // eTag가 없는 경우: URL만으로 중복 확인 (이미 다운로드한 URL)
                isDuplicate = true
            }
        } else {
            // 첫 번째 다운로드
            isDuplicate = false
        }
        
        if !isDuplicate {
            // 새로운 리소스이거나 eTag가 변경된 경우에만 메트릭 업데이트
            self.totalMemory += data.count
            self.totalCount += 1
            if elapsedMS > self.maxElapsedMS {
                self.maxElapsedMS = elapsedMS
            }
            self.displayInfo.onNext(DisplayInfo(memory: self.totalMemory, time: self.maxElapsedMS, count: self.totalCount))
            
            // 다운로드한 리소스 정보 저장
            // eTag가 있으면 eTag 저장, 없으면 빈 문자열로 URL만 추적
            self.downloadedResources[urlString] = eTag.isEmpty ? "" : eTag
            
            Self.logger.info("Image downloaded from \(url.absoluteString, privacy: .public): size=\(data.count) bytes in \(elapsedMS, format: .fixed(precision: 2)) ms, eTag=\(eTag.isEmpty ? "none" : eTag, privacy: .public)")
        } else {
            Self.logger.info("Image skipped (duplicate) from \(url.absoluteString, privacy: .public): eTag=\(eTag.isEmpty ? "none" : eTag, privacy: .public)")
        }

        return image
    }
    
    public func clearData() {
        totalMemory = 0
        maxElapsedMS = 0
        totalCount = 0
        downloadedResources.removeAll()
    }
}
