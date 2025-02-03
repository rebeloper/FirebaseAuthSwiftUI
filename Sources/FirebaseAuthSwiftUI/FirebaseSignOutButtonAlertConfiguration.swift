//
//  FirebaseSignOutButtonAlertConfiguration.swift
//  FirebaseAuthSwiftUI
//
//  Created by Alex Nagy on 03.02.2025.
//

import Foundation

public struct FirebaseSignOutButtonAlertConfiguration {
    let title: String
    let message: String
    let confirmButtonTitle: String
    let cancelButtonTitle: String
    
    public init(title: String = "Sign out", message: String = "Are you sure you want to sign out?", confirmButtonTitle: String = "Confirm", cancelButtonTitle: String = "Cancel") {
        self.title = title
        self.message = message
        self.confirmButtonTitle = confirmButtonTitle
        self.cancelButtonTitle = cancelButtonTitle
    }
}
