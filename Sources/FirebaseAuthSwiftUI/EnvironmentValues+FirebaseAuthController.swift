//
//  EnvironmentValues+FirebaseAuthController.swift
//
//
//  Created by Alex Nagy on 08.05.2024.
//

import SwiftUI

public extension EnvironmentValues {
    var firebaseAuth: FirebaseAuthController {
        get {
            return self[FirebaseAuthControllerKey.self]
        }
        set {
            self[FirebaseAuthControllerKey.self] = newValue
        }
    }
}
