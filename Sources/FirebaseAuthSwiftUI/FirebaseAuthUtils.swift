//
//  FirebaseAuthUtils.swift
//  
//
//  Created by Alex Nagy on 08.05.2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

public struct FirebaseAuthUtils {
    static func isNewUserInFirestore(path: String, uid: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let reference = Firestore.firestore().collection(path)
        reference.document(uid).getDocument { _, error in
            if let error {
                if error._code == 4865 {
                    completion(.success(false))
                } else {
                    completion(.failure(error))
                }
            } else {
                completion(.success(true))
            }
        }
    }
}
