//
//  ConfirmationViewModel.swift
//  raenest-test
//
//  Created by Itunu Raimi on 17/08/2026.
//

import Foundation

enum ConfirmationState: Equatable {
    case idle
    case loading
    case success(String)
    case error(String)
}

final class ConfirmationViewModel {

    let amount: Double
    let currency: String
    let beneficiary: Beneficiary

    private let keychain: KeychainService
    private let biometric: BiometricServiceProtocol
    private let paymentService: PaymentServiceProtocol

    private(set) var state: ConfirmationState = .idle {
        didSet { onStateChange?(state) }
    }

    var onStateChange: ((ConfirmationState) -> Void)?

    var biometryName: String { biometric.biometryName }

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        let symbol: String
        switch currency {
        case "USD": symbol = "$"
        case "NGN": symbol = "₦"
        case "GBP": symbol = "£"
        case "EUR": symbol = "€"
        default: symbol = currency
        }
        return "\(symbol)\(formatted)"
    }

    init(amount: Double,
         currency: String,
         beneficiary: Beneficiary,
         keychain: KeychainService = KeychainService(),
         biometric: BiometricServiceProtocol = BiometricService(),
         paymentService: PaymentServiceProtocol = MockPaymentService()) {
        self.amount = amount
        self.currency = currency
        self.beneficiary = beneficiary
        self.keychain = keychain
        self.biometric = biometric
        self.paymentService = paymentService
    }

    func confirmPayment() async {
        state = .loading

        do {
            _ = try await biometric.authenticate(
                reason: "Authenticate to send \(formattedAmount) to \(beneficiary.fullName)")
        } catch {
            state = .error(error.localizedDescription)
            return
        }

        guard let token = keychain.retrieve(), !token.isEmpty else {
            state = .error(PaymentError.missingToken.localizedDescription)
            return
        }

        let request = PaymentRequest(
            amount: amount,
            currency: currency,
            beneficiary: beneficiary,
            authToken: token
        )

        do {
            let response = try await paymentService.send(request)
            state = .success(response.message)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
