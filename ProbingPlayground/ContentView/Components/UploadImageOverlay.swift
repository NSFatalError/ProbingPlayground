//
//  UploadImageOverlay.swift
//  ProbingPlayground
//
//  Created by Kamil Strzelecki on 07/05/2025.
//  Copyright © 2025 Kamil Strzelecki. All rights reserved.
//

import SwiftUI

struct UploadImageOverlay: View {
    let state: UploadState

    var body: some View {
        VStack(spacing: 16) {
            switch state {
            case .uploading:
                ProgressView().controlSize(.large)
                Text("Uploading...")
            case .success:
                Image(systemName: "checkmark").font(.largeTitle)
                Text("Success!")
            case .error:
                Image(systemName: "exclamationmark.triangle").font(.largeTitle)
                Text("Error!")
            }
        }
        .padding(32)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .transition(
            .scale(scale: 0.5)
            .combined(with: .opacity)
            .animation(.snappy)
        )
    }
}

#Preview {
    UploadImageOverlay(state: .uploading)
}

#Preview {
    UploadImageOverlay(state: .success)
}

#Preview {
    UploadImageOverlay(state: .error)
}
