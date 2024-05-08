//
//  FirebaseAuthControllerKey.swift
//
//
//  Created by Alex Nagy on 08.05.2024.
//

import SwiftUI

public struct FirebaseAuthControllerKey: EnvironmentKey {
    @MainActor
    public static let defaultValue = FirebaseAuthController()
}
