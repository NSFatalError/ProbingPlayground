//
//  Mocks.swift
//  ProbingPlayground
//
//  Created by Kamil Strzelecki on 08/05/2025.
//  Copyright © 2025 Kamil Strzelecki. All rights reserved.
//

@testable import ProbingPlayground
import CoreLocation
import SwiftUI

actor ImageDownloaderMock: ImageDownloader {
    private(set) var shouldFailDownload = false
    private(set) var downloadImageCallsCount = 0

    func downloadImage(withQuality quality: ImageQuality) async throws -> Image {
        downloadImageCallsCount += 1
        guard !shouldFailDownload else {
            throw ErrorMock()
        }
        return Image(systemName: "")
    }

    func setFailDownload(_ shouldFail: Bool) {
        shouldFailDownload = shouldFail
    }
}

actor ImageUploaderMock: ImageUploader {
    private(set) var shouldFailUpload = false
    private(set) var uploadImageCallsCount = 0

    func uploadImage(_ image: Image) async throws {
        uploadImageCallsCount += 1
        guard !shouldFailUpload else {
            throw ErrorMock()
        }
    }

    func setFailUpload(_ shouldFail: Bool) {
        shouldFailUpload = shouldFail
    }
}

actor ImageProcessorMock: ImageProcessor {
    private(set) var processImageCallsCount = 0
    private(set) var clearCacheCallsCount = 0

    func processImage(_ image: Image) async throws -> Image {
        processImageCallsCount += 1
        return image
    }
    
    func clearCache() async {
        clearCacheCallsCount += 1
    }
}

struct LocationProviderMock: LocationProvider {
    typealias Underlying = AsyncThrowingStream<LocationUpdateMock, Error>

    private let stream: Underlying
    let continuation: Underlying.Continuation

    init() {
        let (stream, continuation) = Underlying.makeStream()
        self.stream = stream
        self.continuation = continuation
    }

    func getUpdates() -> any AsyncSequence<any LocationUpdate, any Error> {
        stream.map { $0 as LocationUpdate }
    }
}

struct ImageItemMock: ImageItem {
    func loadImage() async throws -> Image {
        Image(systemName: "")
    }
}

struct LocationUpdateMock: LocationUpdate {
    var location: CLLocation?
    var authorizationDenied = false
}

struct ErrorMock: Error {}
