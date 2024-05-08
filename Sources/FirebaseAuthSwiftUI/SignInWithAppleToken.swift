//
//  SignInWithAppleToken.swift
//
//
//  Created by Alex Nagy on 08.05.2024.
//

import Foundation
import AuthenticationServices

public struct SignInWithAppleToken {
    public let appleIDCredential: ASAuthorizationAppleIDCredential
    public let nonce: String
    public let idTokenString: String
}
