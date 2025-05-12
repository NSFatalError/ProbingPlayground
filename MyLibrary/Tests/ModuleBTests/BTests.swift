//
//  BTests.swift
//  MyLibrary
//
//  Created by Kamil Strzelecki on 08/05/2025.
//  Copyright © 2025 Kamil Strzelecki. All rights reserved.
//

@testable import ModuleB
import ProbeTesting
import Testing

@Test
func sanityCheck() async throws {
    try await withProbing {
        await b()
    } dispatchedBy: { dispatcher in
        try await dispatcher.runUpToProbe("a")
        try await dispatcher.runUpToProbe("b")
    }
}
