//
//  Image+Data.swift
//  ProbingPlayground
//
//  Created by Kamil Strzelecki on 08/05/2025.
//  Copyright © 2025 Kamil Strzelecki. All rights reserved.
//

import SwiftUI

#if canImport(UIKit)
extension Image {
    init?(data: Data) {
        guard let uiImage = UIImage(data: data) else { return nil }
        self.init(uiImage: uiImage)
    }
}

#elseif canImport(AppKit)
extension Image {
    init?(data: Data) {
        guard let nsImage = NSImage(data: data) else { return nil }
        self.init(nsImage: nsImage)
    }
}
#endif
