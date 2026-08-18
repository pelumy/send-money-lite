//
//  Payments.swift
//  raenest-test
//
//  Created by Itunu Raimi on 17/08/2026.
//

import Foundation

struct PaymentRequest {
    let amount: Double
    let currency: String
    let beneficiary: Beneficiary
    let authToken: String
}

struct PaymentResponse {
    let transactionId: String
    let message: String
}

enum PaymentError: LocalizedError {
    case missingToken
    case biometricFailed(String)
    case biometricCancelled
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .missingToken: return "Authentication token not found."
        case .biometricFailed(let reason): return "Authentication failed: \(reason)"
        case .biometricCancelled: return "Authentication was cancelled."
        case .serverError(let msg): return msg
        }
    }
}
