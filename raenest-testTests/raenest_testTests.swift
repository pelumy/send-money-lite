//
//  raenest_testTests.swift
//  raenest-testTests
//
//  Created by Itunu Raimi on 17/08/2026.
//

import XCTest
@testable import raenest_test

@MainActor
final class MockBiometricService: BiometricServiceProtocol {
    var biometryName: String = "Face ID"
    var shouldSucceed = true
    var errorToThrow: Error?

    func authenticate(reason: String) async throws -> Bool {
        if let error = errorToThrow {
            throw error
        }
        if shouldSucceed {
            return true
        }
        throw PaymentError.biometricCancelled
    }
}

@MainActor
final class raenest_testTests: XCTestCase {

    var validationService: ValidationService!
    let mockRules = ValidationRules(minAmount: 10, maxAmount: 20000, allowedCurrencies: ["USD", "NGN", "GBP", "EUR"])

    override func setUp() {
        super.setUp()
        validationService = ValidationService(rules: mockRules)
    }

    override func tearDown() {
        validationService = nil
        super.tearDown()
    }

    func test_validationService_amountBoundaries() {
        // Below minimum
        XCTAssertEqual(validationService.validateAmount("5"), "Minimum is 10")
        XCTAssertFalse(validationService.isAmountValid("5"))

        // Exactly minimum
        XCTAssertNil(validationService.validateAmount("10"))
        XCTAssertTrue(validationService.isAmountValid("10"))

        // Inside bounds
        XCTAssertNil(validationService.validateAmount("500"))
        XCTAssertTrue(validationService.isAmountValid("500"))

        // Exactly maximum
        XCTAssertNil(validationService.validateAmount("20000"))
        XCTAssertTrue(validationService.isAmountValid("20000"))

        // Above maximum
        XCTAssertEqual(validationService.validateAmount("20001"), "Maximum is 20,000")
        XCTAssertFalse(validationService.isAmountValid("20001"))

        // Invalid format
        XCTAssertEqual(validationService.validateAmount("abc"), "Enter a valid number")
        XCTAssertFalse(validationService.isAmountValid("abc"))
    }

    func test_validationService_currencyCheck() {
        XCTAssertTrue(validationService.isCurrencyValid("USD"))
        XCTAssertTrue(validationService.isCurrencyValid("NGN"))
        XCTAssertFalse(validationService.isCurrencyValid("CAD"))
        XCTAssertFalse(validationService.isCurrencyValid("JPY"))
    }

    func test_sendMoneyViewModel_continueButtonState() {
        let mockBeneficiary = Beneficiary(id: "123", fullName: "Test User", bankName: "Test Bank", accountNumber: "12345", currency: "USD")
        let mockBenService = BeneficiaryService()
        let viewModel = SendMoneyViewModel(validationService: validationService, beneficiaryService: mockBenService)

        // Initial state
        XCTAssertFalse(viewModel.isContinueEnabled)

        // Valid amount, but no beneficiary
        viewModel.setAmount("50")
        XCTAssertFalse(viewModel.isContinueEnabled)

        // Select beneficiary
        viewModel.selectBeneficiary(mockBeneficiary)
        XCTAssertTrue(viewModel.isContinueEnabled)

        // Change to invalid amount
        viewModel.setAmount("5")
        XCTAssertFalse(viewModel.isContinueEnabled)
    }

    @MainActor
    func test_confirmationViewModel_success() async {
        let mockBeneficiary = Beneficiary(id: "123", fullName: "Test User", bankName: "Test Bank", accountNumber: "12345", currency: "USD")
        let keychain = KeychainService()
        keychain.save("mock_token")

        let biometric = MockBiometricService()
        biometric.shouldSucceed = true

        let payment = MockPaymentService()
        payment.shouldFail = false

        let viewModel = ConfirmationViewModel(
            amount: 50,
            currency: "USD",
            beneficiary: mockBeneficiary,
            keychain: keychain,
            biometric: biometric,
            paymentService: payment
        )

        XCTAssertEqual(viewModel.state, .idle)

        await viewModel.confirmPayment()

        if case .success(let msg) = viewModel.state {
            XCTAssertTrue(msg.contains("sent to Test User"))
        } else {
            XCTFail("Expected state to be success, got \(viewModel.state)")
        }
    }

    @MainActor
    func test_confirmationViewModel_biometricFailure() async {
        let mockBeneficiary = Beneficiary(id: "123", fullName: "Test User", bankName: "Test Bank", accountNumber: "12345", currency: "USD")
        let keychain = KeychainService()
        keychain.save("mock_token")

        let biometric = MockBiometricService()
        biometric.shouldSucceed = false
        biometric.errorToThrow = PaymentError.biometricCancelled

        let payment = MockPaymentService()

        let viewModel = ConfirmationViewModel(
            amount: 50,
            currency: "USD",
            beneficiary: mockBeneficiary,
            keychain: keychain,
            biometric: biometric,
            paymentService: payment
        )

        await viewModel.confirmPayment()

        if case .error(let reason) = viewModel.state {
            XCTAssertEqual(reason, "Authentication was cancelled.")
        } else {
            XCTFail("Expected state to be error with cancellation message, got \(viewModel.state)")
        }
    }

}
