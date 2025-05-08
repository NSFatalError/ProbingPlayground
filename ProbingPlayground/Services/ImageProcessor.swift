//
//  ImageProcessor.swift
//  ProbingPlayground
//
//  Created by Kamil Strzelecki on 07/05/2025.
//  Copyright © 2025 Kamil Strzelecki. All rights reserved.
//

import SwiftUI

protocol ImageProcessor: Sendable {
    func processImage(_ image: Image) async throws -> Image
    func clearCache() async
}

struct FakeImageProcessor: ImageProcessor {
    func processImage(_ image: Image) async throws -> Image {
        try await Task.sleep(for: .seconds(1))
        return image
    }

    func clearCache() async {
        try? await Task.sleep(for: .seconds(1))
    }
}
