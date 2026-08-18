//
//  SecurityServices.swift
//  raenest-test
//
//  Created by Itunu Raimi on 17/08/2026.
//

import Foundation
import Security
import LocalAuthentication

/// Stores and retrieves a mock auth token from the Keychain.

final class KeychainService {

    private let service = "com.raenest.sendmoney"
    private let account = "auth_token"
    private static var fallback: String?

    func save(_ token: String) {
        if let data = token.data(using: .utf8) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account,
                kSecValueData as String: data
            ]
            SecItemDelete(query as CFDictionary)
            let status = SecItemAdd(query as CFDictionary, nil)
            if status != errSecSuccess {
                Self.fallback = token // simulator fallback
            }
        }
        Self.fallback = token
    }

    func retrieve() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecSuccess, let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }
        return Self.fallback
    }

    /// Pre-populates a default mock token if none exists.
    func prepopulateIfNeeded() {
        if retrieve() == nil {
            save("mock_bearer_token_raenest_2026")
        }
    }
}

protocol BiometricServiceProtocol {
    var biometryName: String { get }
    func authenticate(reason: String) async throws -> Bool
}

/// Wraps LocalAuthentication for Face ID / Touch ID.
final class BiometricService: BiometricServiceProtocol {

    var biometryName: String {
        let context = LAContext()
        var error: NSError?
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        switch context.biometryType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        default: return "Passcode"
        }
    }

    func authenticate(reason: String) async throws -> Bool {
        let context = LAContext()
        var error: NSError?

        let policy: LAPolicy
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            policy = .deviceOwnerAuthenticationWithBiometrics
        } else if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            policy = .deviceOwnerAuthentication
        } else {
            throw PaymentError.biometricFailed(error?.localizedDescription ?? "Not available")
        }

        return try await withCheckedThrowingContinuation { continuation in
            context.evaluatePolicy(policy, localizedReason: reason) { success, evalError in
                if success {
                    continuation.resume(returning: true)
                } else if let err = evalError as? LAError,
                          err.code == .userCancel || err.code == .appCancel {
                    continuation.resume(throwing: PaymentError.biometricCancelled)
                } else {
                    continuation.resume(throwing: PaymentError.biometricFailed(
                        evalError?.localizedDescription ?? "Failed"))
                }
            }
        }
    }
}
