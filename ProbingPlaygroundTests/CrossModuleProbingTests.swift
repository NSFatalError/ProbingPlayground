//
//  ModuleTests.swift
//  ProbingPlayground
//
//  Created by Kamil Strzelecki on 10/05/2025.
//  Copyright © 2025 Kamil Strzelecki. All rights reserved.
//

@testable import ProbingPlayground
import ProbeTesting
import Testing

@Test(.tags(.probes))
func testCrossModuleProbing() async throws {
    try await withProbing {
        await crossModuleCall()
    } dispatchedBy: { dispatcher in
        try await dispatcher.runUpToProbe("a")
        try await dispatcher.runUpToProbe("b")
        try await dispatcher.runUpToProbe("playground")
    }
}
