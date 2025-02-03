//
//  FirebaseSignOutButton.swift
//  Carrrds
//
//  Created by Alex Nagy on 03.02.2025.
//

import SwiftUI

public struct FirebaseSignOutButton<Label: View>: View {
    
    @Environment(\.firebaseAuth) private var firebaseAuth
    
    let alertConfiguration: FirebaseSignOutButtonAlertConfiguration
    @ViewBuilder var label: () -> Label
    let onError: ((Error) -> Void)?
    
    public init(alertConfiguration: FirebaseSignOutButtonAlertConfiguration = FirebaseSignOutButtonAlertConfiguration(),
         @ViewBuilder label: @escaping () -> Label,
         onError: ((Error) -> Void)? = nil) {
        self.alertConfiguration = alertConfiguration
        self.label = label
        self.onError = onError
    }
    
    @State private var isSignOutAlertPresented = false
    
    public var body: some View {
        Button {
            isSignOutAlertPresented.toggle()
        } label: {
            label()
        }
        .alert(alertConfiguration.title, isPresented: $isSignOutAlertPresented) {
            Button(alertConfiguration.confirmButtonTitle, role: .destructive) {
                do {
                    try firebaseAuth.signOut()
                } catch {
                    onError?(error)
                }
            }
            Button(alertConfiguration.cancelButtonTitle, role: .cancel) {
                
            }
        } message: {
            Text(alertConfiguration.message)
        }
    }
}
