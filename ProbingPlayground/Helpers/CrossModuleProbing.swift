//
//  CrossModuleProbing.swift
//  ProbingPlayground
//
//  Created by Kamil Strzelecki on 10/05/2025.
//  Copyright © 2025 Kamil Strzelecki. All rights reserved.
//

import ModuleB
import Probing

func crossModuleCall() async {
    await b()
    await #probe("playground")
}
