//
//  ImageUploader.swift
//  ProbingPlayground
//
//  Created by Kamil Strzelecki on 07/05/2025.
//  Copyright © 2025 Kamil Strzelecki. All rights reserved.
//

import SwiftUI

protocol ImageUploader: Sendable {
    func uploadImage(_ image: Image) async throws
}

struct FakeImageUploader: ImageUploader {
    static let failUploadKey = "failUpload"

    func uploadImage(_ image: Image) async throws {
        try await Task.sleep(for: .seconds(1))
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: Self.failUploadKey) {
            throw UploadError()
        }
    }
}

extension FakeImageUploader {
    struct UploadError: Error {}
}
