//
//  SignInWithAppleError.swift
//
//
//  Created by Alex Nagy on 08.05.2024.
//

import Foundation

public enum SignInWithAppleError: Error {
    case noIdentityToken
    case noTokenString
    case noAppleIdCredential
    case noAuthDataResult
    case noCurrentUser
}

extension SignInWithAppleError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noIdentityToken:
            return NSLocalizedString(
                "The identity token is missing.",
                comment: "No Identity Token"
            )
        case .noTokenString:
            return NSLocalizedString(
                "The token string is missing.",
                comment: "No Token String"
            )
        case .noAppleIdCredential:
            return NSLocalizedString(
                "The Apple Id credential is missing.",
                comment: "No Apple Id Credential"
            )
        case .noAuthDataResult:
            return NSLocalizedString(
                "The Auth Data Result is missing.",
                comment: "No Auth Data Result"
            )
        case .noCurrentUser:
            return NSLocalizedString(
                "The Current User is missing.",
                comment: "No Current User"
            )
        }
    }
}
