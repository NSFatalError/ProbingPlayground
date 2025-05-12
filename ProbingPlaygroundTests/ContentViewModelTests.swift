//
//  ContentViewModelTests.swift
//  ProbingPlayground
//
//  Created by Kamil Strzelecki on 07/05/2025.
//  Copyright © 2025 Kamil Strzelecki. All rights reserved.
//

@testable import ProbingPlayground
import ProbeTesting
import Testing

struct ContentViewModelTests {
    private let downloader: ImageDownloaderMock
    private let uploader: ImageUploaderMock
    private let processor: ImageProcessorMock
    private let locationProvider: LocationProviderMock
    private let viewModel: ContentViewModel

    @MainActor
    init() async {
        self.downloader = ImageDownloaderMock()
        self.uploader = ImageUploaderMock()
        self.processor = ImageProcessorMock()
        self.locationProvider = LocationProviderMock()

        self.viewModel = ContentViewModel(
            downloader: downloader,
            uploader: uploader,
            processor: processor,
            locationProvider: locationProvider
        )

        viewModel.uploadingFinishedPresentationDuration = .zero
    }
}

extension ContentViewModelTests {

    @Test(.tags(.probes))
    func testUploadingImage() async throws {
        try await withProbing {
            let item = ImageItemMock()
            await viewModel.uploadImage(item)
        } dispatchedBy: { dispatcher in
            await #expect(viewModel.uploadState == nil)

            try await dispatcher.runUpToProbe()
            await #expect(processor.processImageCallsCount == 0)
            await #expect(uploader.uploadImageCallsCount == 0)
            await #expect(viewModel.uploadState == .uploading)

            try await dispatcher.runUpToProbe("uploadingFinished")
            await #expect(processor.processImageCallsCount == 1)
            await #expect(uploader.uploadImageCallsCount == 1)
            await #expect(viewModel.uploadState == .success)

            try await dispatcher.runUntilExitOfBody()
            await #expect(processor.clearCacheCallsCount == 0)
            await #expect(viewModel.uploadState == nil)

            try await dispatcher.runUntilEverythingCompleted()
            await #expect(processor.clearCacheCallsCount == 1)
        }
    }

    @Test(.tags(.probes))
    func testUploadingImageFailure() async throws {
        try await withProbing {
            let item = ImageItemMock()
            await viewModel.uploadImage(item)
        } dispatchedBy: { dispatcher in
            await #expect(viewModel.uploadState == nil)

            try await dispatcher.runUpToProbe()
            await #expect(processor.processImageCallsCount == 0)
            await #expect(uploader.uploadImageCallsCount == 0)
            await #expect(viewModel.uploadState == .uploading)

            await uploader.setFailUpload(true)
            try await dispatcher.runUpToProbe("uploadingFinished")
            await #expect(processor.processImageCallsCount == 1)
            await #expect(uploader.uploadImageCallsCount == 1)
            await #expect(viewModel.uploadState == .error)

            try await dispatcher.runUntilExitOfBody()
            await #expect(processor.clearCacheCallsCount == 0)
            await #expect(viewModel.uploadState == nil)

            try await dispatcher.runUntilEverythingCompleted()
            await #expect(processor.clearCacheCallsCount == 1)
        }
    }
}

extension ContentViewModelTests {

    @Test(.tags(.asyncSequence))
    func testUpdatingLocation() async throws {
        try await withProbing {
            await viewModel.beginUpdatingLocation()
        } dispatchedBy: { dispatcher in
            await #expect(viewModel.locationState == nil)

            locationProvider.continuation.yield(.init(location: .sanFrancisco))
            try await dispatcher.runUpToProbe(inEffect: "location")
            await #expect(viewModel.locationState == .near)

            locationProvider.continuation.yield(.init(location: .init(latitude: 0, longitude: 0)))
            try await dispatcher.runUpToProbe(inEffect: "location")
            await #expect(viewModel.locationState == .far)

            locationProvider.continuation.yield(.init(location: .sanFrancisco))
            try await dispatcher.runUpToProbe(inEffect: "location")
            await #expect(viewModel.locationState == .near)

            locationProvider.continuation.yield(.init(location: nil, authorizationDenied: true))
            try await dispatcher.runUpToProbe(inEffect: "location")
            await #expect(viewModel.locationState == .error)

            locationProvider.continuation.yield(.init(location: .sanFrancisco))
            try await dispatcher.runUpToProbe(inEffect: "location")
            await #expect(viewModel.locationState == .near)
        }
    }

    @Test(.tags(.asyncSequence))
    func testUpdatingLocationFailure() async throws {
        try await withProbing {
            await viewModel.beginUpdatingLocation()
        } dispatchedBy: { dispatcher in
            await #expect(viewModel.locationState == nil)

            locationProvider.continuation.yield(.init(location: .sanFrancisco))
            try await dispatcher.runUpToProbe(inEffect: "location")
            await #expect(viewModel.locationState == .near)

            locationProvider.continuation.finish(throwing: ErrorMock())
            try await dispatcher.runUntilEffectCompleted("location")
            await #expect(viewModel.locationState == .error)
        }
    }
}

extension ContentViewModelTests {

    @Test(.tags(.effects))
    func testDownloadingImageWhenLowQualityDownloadSucceedsFirst() async throws {
        try await withProbing {
            await viewModel.downloadImage()
        } dispatchedBy: { dispatcher in
            await #expect(viewModel.downloadState == nil)

            try await dispatcher.runUntilExitOfBody()
            await #expect(viewModel.downloadState?.isDownloading == true)

            try await dispatcher.runUntilEffectCompleted("low0")
            await #expect(viewModel.downloadState?.quality == .low)

            try await dispatcher.runUntilEffectCompleted("high0")
            await #expect(viewModel.downloadState?.quality == .high)
        }
    }

    @Test(.tags(.effects))
    func testDownloadingImageWhenHighQualityDownloadSucceedsFirst() async throws {
        try await withProbing {
            await viewModel.downloadImage()
        } dispatchedBy: { dispatcher in
            await #expect(viewModel.downloadState == nil)

            try await dispatcher.runUntilExitOfBody()
            await #expect(viewModel.downloadState?.isDownloading == true)

            try await dispatcher.runUntilEffectCompleted("high0")
            await #expect(viewModel.downloadState?.quality == .high)

            try await dispatcher.runUntilEffectCompleted("low0")
            try dispatcher.getCancelledValue(fromEffect: "low0", as: Void.self)
            await #expect(viewModel.downloadState?.quality == .high)
        }
    }

    @Test(.tags(.effects))
    func testDownloadingImageWhenLowQualityDownloadFailsFirst() async throws {
        try await withProbing {
            await viewModel.downloadImage()
        } dispatchedBy: { dispatcher in
            await #expect(viewModel.downloadState == nil)

            try await dispatcher.runUntilExitOfBody()
            await #expect(viewModel.downloadState?.isDownloading == true)

            await downloader.setFailDownload(true)
            try await dispatcher.runUntilEffectCompleted("low0")
            await #expect(viewModel.downloadState?.isDownloading == true)

            await downloader.setFailDownload(false)
            try await dispatcher.runUntilEffectCompleted("high0")
            await #expect(viewModel.downloadState?.quality == .high)
        }
    }

    @Test(.tags(.effects))
    func testDownloadingImageWhenLowQualityDownloadFailsAfterHighQualityDownloadSucceeds() async throws {
        try await withProbing {
            await viewModel.downloadImage()
        } dispatchedBy: { dispatcher in
            await #expect(viewModel.downloadState == nil)

            try await dispatcher.runUntilExitOfBody()
            await #expect(viewModel.downloadState?.isDownloading == true)

            try await dispatcher.runUntilEffectCompleted("high0")
            await #expect(viewModel.downloadState?.quality == .high)

            await downloader.setFailDownload(true)
            try await dispatcher.runUntilEffectCompleted("low0")
            try dispatcher.getCancelledValue(fromEffect: "low0", as: Void.self)
            await #expect(viewModel.downloadState?.quality == .high)
        }
    }

    @Test(.tags(.effects))
    func testDownloadingImageWhenHighQualityDownloadFailsFirst() async throws {
        try await withProbing {
            await viewModel.downloadImage()
        } dispatchedBy: { dispatcher in
            await #expect(viewModel.downloadState == nil)

            try await dispatcher.runUntilExitOfBody()
            await #expect(viewModel.downloadState?.isDownloading == true)

            await downloader.setFailDownload(true)
            try await dispatcher.runUntilEffectCompleted("high0")
            await #expect(viewModel.downloadState?.isDownloading == true)

            await downloader.setFailDownload(false)
            try await dispatcher.runUntilEffectCompleted("low0")
            await #expect(viewModel.downloadState?.quality == .low)
        }
    }

    @Test(.tags(.effects))
    func testDownloadingImageWhenHighQualityDownloadFailsAfterLowQualityDownloadSucceeds() async throws {
        try await withProbing {
            await viewModel.downloadImage()
        } dispatchedBy: { dispatcher in
            await #expect(viewModel.downloadState == nil)

            try await dispatcher.runUntilExitOfBody()
            await #expect(viewModel.downloadState?.isDownloading == true)

            try await dispatcher.runUntilEffectCompleted("low0")
            await #expect(viewModel.downloadState?.quality == .low)

            await downloader.setFailDownload(true)
            try await dispatcher.runUntilEffectCompleted("high0")
            await #expect(viewModel.downloadState?.quality == .low)
        }
    }

    @Test(.tags(.effects))
    func testDownloadingImageWhenBothDownloadsFail() async throws {
        try await withProbing {
            await viewModel.downloadImage()
        } dispatchedBy: { dispatcher in
            await #expect(viewModel.downloadState == nil)

            try await dispatcher.runUntilExitOfBody()
            await #expect(viewModel.downloadState?.isDownloading == true)

            await downloader.setFailDownload(true)
            try await dispatcher.runUntilEffectCompleted("low0")
            await #expect(viewModel.downloadState?.isDownloading == true)

            try await dispatcher.runUntilEffectCompleted("high0")
            await #expect(viewModel.downloadState?.isError == true)
        }
    }

    @Test(.tags(.effects))
    func testDownloadingImageRepeatedly() async throws {
        try await withProbing {
            await viewModel.downloadImage()
            await viewModel.downloadImage()
        } dispatchedBy: { dispatcher in
            await #expect(viewModel.downloadState == nil)

            try await dispatcher.runUntilExitOfBody()
            await #expect(viewModel.downloadState?.isDownloading == true)

            try await dispatcher.runUntilEffectCompleted("low0")
            try dispatcher.getCancelledValue(fromEffect: "low0", as: Void.self)
            await #expect(viewModel.downloadState?.isDownloading == true)

            try await dispatcher.runUntilEffectCompleted("high0")
            try dispatcher.getCancelledValue(fromEffect: "high0", as: Void.self)
            await #expect(viewModel.downloadState?.isDownloading == true)

            try await dispatcher.runUntilEffectCompleted("low1")
            await #expect(viewModel.downloadState?.quality == .low)

            try await dispatcher.runUntilEffectCompleted("high1")
            await #expect(viewModel.downloadState?.quality == .high)
        }
    }
}
