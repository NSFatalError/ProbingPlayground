//
//  ContentView.swift
//  ProbingPlayground
//
//  Created by Kamil Strzelecki on 07/05/2025.
//  Copyright © 2025 Kamil Strzelecki. All rights reserved.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var isShowingOptions = false
    @State private var viewModel = ContentViewModel(
        downloader: DiskImageDownloader(),
        uploader: FakeImageUploader(),
        processor: FakeImageProcessor(),
        locationProvider: SystemLocationProvider()
    )

    var body: some View {
        VStack {
            VStack(spacing: 16) {
                Text("San Francisco")
                    .font(.largeTitle.bold())
                if let locationState = viewModel.locationState {
                    LocationBanner(state: locationState)
                }
            }
            .padding()

            if let downloadState = viewModel.downloadState {
                DownloadedImageView(state: downloadState)
            }

            bottomBar.padding()
        }
        .onAppear {
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
        .overlay {
            if let uploadState = viewModel.uploadState {
                UploadImageOverlay(state: uploadState)
            }
        }
        .frame(
            minWidth: 350,
            minHeight: 500
        )
    }

    private var bottomBar: some View {
        UploadImageButton { item in
            Task { await viewModel.uploadImage(item) }
        }
        .disabled(viewModel.areUploadsDisabled)
        .frame(maxWidth: .infinity)
        .overlay(alignment: .leading) {
            Button {
                viewModel.downloadImage()
            } label: {
                Image(systemName: "arrow.clockwise")
            }
        }
        .overlay(alignment: .trailing) {
            Button {
                isShowingOptions = true
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .sheet(isPresented: $isShowingOptions) {
                OptionsView()
            }
        }
    }
}

private struct OptionsView: View {
    @AppStorage(DiskImageDownloader.failLowQualityDownloadKey)
    private var failLowQualityDownload = false

    @AppStorage(DiskImageDownloader.failHighQualityDownloadKey)
    private var failHighQualityDownload = false

    @AppStorage(FakeImageUploader.failUploadKey)
    private var failUpload = false

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        Form {
            Section {
                Toggle("Fail low quality download", isOn: $failLowQualityDownload)
                Toggle("Fail high quality download", isOn: $failHighQualityDownload)
            }

            Section {
                Toggle("Fail upload", isOn: $failUpload)
            }
        }
        #if os(macOS)
        .padding()
        .toolbar {
            Button("Close") {
                dismiss()
            }
        }
        #endif
    }
}

#Preview {
    ContentView()
}
