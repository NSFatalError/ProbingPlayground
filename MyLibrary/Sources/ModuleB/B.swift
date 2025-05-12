//
//  B.swift
//  MyLibrary
//
//  Created by Kamil Strzelecki on 08/05/2025.
//  Copyright © 2025 Kamil Strzelecki. All rights reserved.
//

import Probing
import ModuleA

public func b() async {
    await a()
    await #probe("b")
}
