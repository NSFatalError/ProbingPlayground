//
//  UploadImageButton.swift
//  ProbingPlayground
//
//  Created by Kamil Strzelecki on 08/05/2025.
//  Copyright © 2025 Kamil Strzelecki. All rights reserved.
//

import SwiftUI
import PhotosUI

struct UploadImageButton: View {
    @State private var selection: PhotosPickerItem? = nil
    let onSelected: (ImageItem) -> Void

    var body: some View {
        PhotosPicker(
            "Upload your image",
            selection: $selection
        )
        .buttonBorderShape(.capsule)
        .buttonStyle(.borderedProminent)
        .onChange(of: selection) {
            if let item = selection.take() {
                onSelected(item)
            }
        }
    }
}
