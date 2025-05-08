//
//  ImageDownloader.swift
//  ProbingPlayground
//
//  Created by Kamil Strzelecki on 07/05/2025.
//  Copyright © 2025 Kamil Strzelecki. All rights reserved.
//

import SwiftUI
import Foundation

protocol ImageDownloader: Sendable {
    func downloadImage(withQuality quality: ImageQuality) async throws -> Image
}

enum ImageQuality: Int, Comparable, CustomStringConvertible {
    case low
    case high

    var description: String {
        switch self {
        case .low: "low"
        case .high: "high"
        }
    }

    static func < (lhs: ImageQuality, rhs: ImageQuality) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

struct DiskImageDownloader: ImageDownloader {
    static let failLowQualityDownloadKey = "failLowQualityDownload"
    static let failHighQualityDownloadKey = "failHighQualityDownload"

    func downloadImage(withQuality quality: ImageQuality) async throws -> Image {
        let resourceName = String(describing: quality)
        let processingTime = processingTime(forImageWithQuality: quality)
        try await Task.sleep(for: processingTime)

        guard let url = Bundle.main.url(forResource: resourceName, withExtension: "jpg") else {
            throw DownloadError()
        }

        let data = try Data(contentsOf: url)
        guard let image = Image(data: data) else {
            throw DownloadError()
        }

        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: Self.failLowQualityDownloadKey), quality == .low {
            throw DownloadError()
        }
        if userDefaults.bool(forKey: Self.failHighQualityDownloadKey), quality == .high {
            throw DownloadError()
        }

        return image
    }

    private func processingTime(forImageWithQuality quality: ImageQuality) -> Duration {
        switch quality {
        case .low: .seconds(.random(in: 0.2...1.0))
        case .high: .seconds(.random(in: 0.5...2.0))
        }
    }
}

extension DiskImageDownloader {
    private struct DownloadError: Error {}
}
