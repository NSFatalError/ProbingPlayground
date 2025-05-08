//
//  LocationBanner.swift
//  ProbingPlayground
//
//  Created by Kamil Strzelecki on 08/05/2025.
//  Copyright © 2025 Kamil Strzelecki. All rights reserved.
//

import SwiftUI

struct LocationBanner: View {
    let state: LocationState

    var body: some View {
        HStack {
            switch state {
            case .unknown:
                ProgressView().controlSize(.small)
                Text("Checking...")
            case .far:
                Text("You're far away from the city")
            case .near:
                Text("You're near the city - upload your image!")
            case .error:
                Text("Error!")
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.quaternary)
        }
    }
}

#Preview {
    LocationBanner(state: .unknown)
}

#Preview {
    LocationBanner(state: .far)
}

#Preview {
    LocationBanner(state: .near)
}

#Preview {
    LocationBanner(state: .error)
}
