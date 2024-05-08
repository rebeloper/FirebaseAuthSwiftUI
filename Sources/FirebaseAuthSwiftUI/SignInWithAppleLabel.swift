//
//  SignInWithAppleLabel.swift
//
//
//  Created by Alex Nagy on 08.05.2024.
//

import SwiftUI

public struct SignInWithAppleLabel: View {
    
    private let title: String
    
    /// Sign in with Apple label
    /// - Parameter title: title
    public init(_ title: String) {
        self.title = title
    }
    
    /// Sign in with Apple label
    /// - Parameter type: the title type
    public init(_ type: SignInWithAppleLabelType = .continueWithApple) {
        switch type {
        case .signIn:
            title = "Sign in with Apple"
        case .signUp:
            title = "Sign up with Apple"
        case .continueWithApple:
            title = "Continue with Apple"
        case .custom(let text):
            title = text
        }
    }
    
    public var body: some View {
        Label(title, systemImage: "applelogo")
            .buttonStyle(.plain)
            .padding(.vertical, 14)
            .padding(.horizontal, 18)
            .bold()
            .foregroundColor(.white)
            .background(.black)
            .cornerRadius(6)
    }
}
