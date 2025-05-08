//
//  DownloadedImageView.swift
//  ProbingPlayground
//
//  Created by Kamil Strzelecki on 08/05/2025.
//  Copyright © 2025 Kamil Strzelecki. All rights reserved.
//

import SwiftUI

struct DownloadedImageView: View {
    let state: DownloadState

    var body: some View {
        VStack {
            switch state {
            case .downloading:
                ProgressView().controlSize(.extraLarge)
            case .error:
                Image(systemName: "exclamationmark.triangle").font(.largeTitle)
                Text("Error!")

            case let .success(quality, image):
                image.resizable()
                    .overlay(alignment: .topTrailing) {
                        if quality == .high {
                            Image(systemName: "sparkles")
                                .padding(8)
                                .background(.regularMaterial)
                                .clipShape(Circle())
                                .padding()
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
        .aspectRatio(1.5, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .background(.quinary)
    }
}

#Preview {
    DownloadedImageView(state: .downloading)
}

#Preview {
    DownloadedImageView(state: .error)
}
