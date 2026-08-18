//
//  ValidationService.swift
//  raenest-test
//
//  Created by Itunu Raimi on 17/08/2026.
//

import Foundation

/// Loads and applies validation rules from the bundled JSON config.

final class ValidationService {

    private(set) var rules: ValidationRules

    init(bundle: Bundle = .main) throws {
        guard let url = bundle.url(forResource: "validation_rules", withExtension: "json") else {
            throw NSError(domain: "ValidationService", code: 404,
                          userInfo: [NSLocalizedDescriptionKey: "validation_rules.json not found"])
        }
        let data = try Data(contentsOf: url)
        self.rules = try JSONDecoder().decode(ValidationRules.self, from: data)
    }

    /// Testable initializer that accepts rules directly.
    init(rules: ValidationRules) {
        self.rules = rules
    }

    func validateAmount(_ text: String) -> String? {
        let cleaned = text.replacingOccurrences(of: ",", with: "").trimmingCharacters(in: .whitespaces)
        guard !cleaned.isEmpty else { return nil } // no error for empty (just disable button)
        guard let amount = Double(cleaned), amount >= 0 else { return "Enter a valid number" }
        if amount < rules.minAmount { return "Minimum is \(Int(rules.minAmount))" }
        if amount > rules.maxAmount { return "Maximum is \(formatted(rules.maxAmount))" }
        return nil
    }

    func isAmountValid(_ text: String) -> Bool {
        guard let amount = Double(text.replacingOccurrences(of: ",", with: "").trimmingCharacters(in: .whitespaces)),
              amount >= rules.minAmount, amount <= rules.maxAmount else { return false }
        return true
    }

    func isCurrencyValid(_ currency: String) -> Bool {
        rules.allowedCurrencies.contains(currency)
    }

    private func formatted(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    }
}
