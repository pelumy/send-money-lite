//
//  PaymentService.swift
//  raenest-test
//
//  Created by Itunu Raimi on 17/08/2026.
//

import Foundation

/// Mocked POST /send implementation.

protocol PaymentServiceProtocol {
    func send(_ request: PaymentRequest) async throws -> PaymentResponse
}

final class MockPaymentService: PaymentServiceProtocol {

    var shouldFail = false

    func send(_ request: PaymentRequest) async throws -> PaymentResponse {
        // Simulate network latency
        try await Task.sleep(nanoseconds: 1_000_000_000)

        guard !request.authToken.isEmpty else {
            throw PaymentError.missingToken
        }

        if shouldFail {
            throw PaymentError.serverError("Server error. Please try again.")
        }

        return PaymentResponse(
            transactionId: "TXN-\(Int.random(in: 100000...999999))",
            message: "Payment of \(request.currency) \(String(format: "%.2f", request.amount)) sent to \(request.beneficiary.fullName)."
        )
    }
}
