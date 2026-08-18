//
//  SendMoneyViewModel.swift
//  raenest-test
//
//  Created by Itunu Raimi on 17/08/2026.
//

import Foundation

final class SendMoneyViewModel {

    private let validationService: ValidationService
    private let beneficiaryService: BeneficiaryService

    private(set) var allBeneficiaries: [Beneficiary] = []
    private(set) var filteredBeneficiaries: [Beneficiary] = []
    private(set) var selectedBeneficiary: Beneficiary?
    private(set) var selectedCurrency: String
    private(set) var amountText: String = ""
    private(set) var amountError: String?

    var onUpdate: (() -> Void)?

    var currencies: [String] { validationService.rules.allowedCurrencies }

    var isContinueEnabled: Bool {
        validationService.isAmountValid(amountText) &&
        validationService.isCurrencyValid(selectedCurrency) &&
        selectedBeneficiary != nil
    }

    var parsedAmount: Double? {
        Double(amountText.replacingOccurrences(of: ",", with: "").trimmingCharacters(in: .whitespaces))
    }

    var limitsHint: String {
        "Min: \(Int(validationService.rules.minAmount)) · Max: \(Int(validationService.rules.maxAmount))"
    }

    init(validationService: ValidationService, beneficiaryService: BeneficiaryService = BeneficiaryService()) {
        self.validationService = validationService
        self.beneficiaryService = beneficiaryService
        self.selectedCurrency = validationService.rules.allowedCurrencies.first ?? "USD"
    }

    func loadBeneficiaries() {
        do {
            allBeneficiaries = try beneficiaryService.load()
            filteredBeneficiaries = allBeneficiaries
        } catch {
            allBeneficiaries = []
            filteredBeneficiaries = []
        }
        onUpdate?()
    }

    func setAmount(_ text: String) {
        amountText = text
        amountError = validationService.validateAmount(text)
        onUpdate?()
    }

    func selectCurrency(_ currency: String) {
        selectedCurrency = currency
        onUpdate?()
    }

    func selectBeneficiary(_ beneficiary: Beneficiary) {
        selectedBeneficiary = beneficiary
        onUpdate?()
    }

    func search(_ query: String) {
        filteredBeneficiaries = beneficiaryService.filter(allBeneficiaries, query: query)
        onUpdate?()
    }

    func reset() {
        amountText = ""
        amountError = nil
        selectedBeneficiary = nil
        filteredBeneficiaries = allBeneficiaries
        onUpdate?()
    }
}
