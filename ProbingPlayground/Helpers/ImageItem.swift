//
//  ImageItem.swift
//  ProbingPlayground
//
//  Created by Kamil Strzelecki on 07/05/2025.
//  Copyright © 2025 Kamil Strzelecki. All rights reserved.
//

import SwiftUI
import PhotosUI

protocol ImageItem: Sendable {
    func loadImage() async throws -> Image
}

extension PhotosPickerItem: ImageItem {
    func loadImage() async throws -> Image {
        guard let image = try await loadTransferable(type: Image.self) else {
            throw LoadingError()
        }
        return image
    }
}

extension PhotosPickerItem {
    struct LoadingError: Error {}
}
