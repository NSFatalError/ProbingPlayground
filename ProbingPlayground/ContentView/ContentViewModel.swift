//
//  ContentViewModel.swift
//  ProbingPlayground
//
//  Created by Kamil Strzelecki on 07/05/2025.
//  Copyright © 2025 Kamil Strzelecki. All rights reserved.
//

import Probing
import Observation
import CoreLocation
import SwiftUI

@MainActor @Observable
final class ContentViewModel {
    private(set) var downloadState: DownloadState?
    private(set) var uploadState: UploadState?
    private(set) var locationState: LocationState?

    private var downloadImageEffects = [DownloadID: any Effect<Void>]()
    private var locationUpdatesEffect: (any Effect<Void>)?

    private let downloader: ImageDownloader
    private let uploader: ImageUploader
    private let processor: ImageProcessor
    private let locationProvider: LocationProvider

    var uploadingFinishedPresentationDuration = Duration.seconds(3)
    var areUploadsDisabled: Bool {
        switch (locationState, uploadState) {
        case (.near, nil): false
        default: true
        }
    }

    init(
        downloader: ImageDownloader,
        uploader: ImageUploader,
        processor: ImageProcessor,
        locationProvider: LocationProvider
    ) {
        self.downloader = downloader
        self.uploader = uploader
        self.processor = processor
        self.locationProvider = locationProvider
    }

    // MARK: Lifecycle

    func onAppear() {
        beginUpdatingLocation()
        downloadImage()
    }

    func onDisappear() {
        downloadImageEffects.values.forEach { $0.cancel() }
        downloadImageEffects.removeAll()
        locationUpdatesEffect?.cancel()
        locationUpdatesEffect = nil
    }

    // MARK: Effects

    // Note: All references to `self` in #Effect macros are needed due to a bug in the compiler.
    // After the fix is released, you won't need to specify them explicitly, just like with the standard Task.init.
    // https://github.com/swiftlang/swift/issues/80561

    func downloadImage() {
        downloadImageEffects.values.forEach { $0.cancel() }
        downloadImageEffects.removeAll()
        downloadState = .downloading

        downloadImage(withQuality: .low)
        downloadImage(withQuality: .high)
    }

    private func downloadImage(withQuality quality: ImageQuality) {
        let id = DownloadID(quality: quality)
        downloadImageEffects[id] = #Effect(.enumerated("\(quality)")) {
            defer {
                self.downloadImageEffects[id] = nil
            }

            do {
                let image = try await self.downloader.downloadImage(withQuality: quality)
                try Task.checkCancellation()
                self.imageDownloadSucceeded(with: image, quality: quality)
            } catch is CancellationError {
                return
            } catch {
                self.imageDownloadFailed()
            }
        }
    }

    private func imageDownloadSucceeded(with image: Image, quality: ImageQuality) {
        switch downloadState {
        case .success(let currentQuality, _) where currentQuality > quality:
            break

        case nil, .downloading, .error, .success:
            downloadState = .success(quality: quality, image: image)
            for (id, effect) in downloadImageEffects {
                if id.quality < quality {
                    effect.cancel()
                }
            }
        }
    }

    private func imageDownloadFailed() {
        switch downloadState {
        case nil, .error:
            downloadState = .error
        case .downloading where downloadImageEffects.count == 1:
            downloadState = .error
        case .downloading, .success:
            break
        }
    }

    // MARK: Probes

    func uploadImage(_ item: ImageItem) async {
        do {
            uploadState = .uploading
            await #probe()
            let image = try await item.loadImage()
            let processedImage = try await processor.processImage(image)
            try await uploader.uploadImage(processedImage)
            uploadState = .success
        } catch {
            uploadState = .error
        }

        await #probe("uploadingFinished")
        try? await Task.sleep(for: uploadingFinishedPresentationDuration)
        uploadState = nil

        #Effect("processorCleanup") { @concurrent in
            await self.processor.clearCache()
        }
    }

    // MARK: AsyncSequence

    func beginUpdatingLocation() {
        locationState = .unknown
        locationUpdatesEffect = #Effect("location") {
            do {
                for try await update in self.locationProvider.getUpdates() {
                    try Task.checkCancellation()

                    if update.authorizationDenied {
                        self.locationState = .error
                    } else if let isNear = update.location?.isNearSanFrancisco() {
                        self.locationState = isNear ? .near : .far
                    } else {
                        self.locationState = .unknown
                    }
                    await #probe()
                }
            } catch {
                self.locationState = .error
            }
        }
    }
}

// MARK: - States

enum DownloadState {
    case downloading
    case success(quality: ImageQuality, image: Image)
    case error

    var isDownloading: Bool {
        switch self {
        case .downloading: true
        default: false
        }
    }

    var isError: Bool {
        switch self {
        case .error: true
        default: false
        }
    }

    var quality: ImageQuality? {
        switch self {
        case let .success(quality, _): quality
        default: nil
        }
    }
}

enum UploadState {
    case uploading
    case success
    case error
}

enum LocationState {
    case unknown
    case near
    case far
    case error
}

// MARK: - Helpers

private struct DownloadID: Hashable {
    let quality: ImageQuality
    let id = UUID()
}

extension CLLocation {
    static let sanFrancisco = CLLocation(
        latitude: 37.7749,
        longitude: -122.4194
    )
    
    func isNearSanFrancisco() -> Bool {
        let distance = distance(from: CLLocation.sanFrancisco)
        return distance < 10_000
    }
}
