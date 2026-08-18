//
//  BeneficiaryService.swift
//  raenest-test
//
//  Created by Itunu Raimi on 17/08/2026.
//

import Foundation

/// Loads beneficiaries from the bundled JSON file.
final class BeneficiaryService {

    func load(bundle: Bundle = .main) throws -> [Beneficiary] {
        guard let url = bundle.url(forResource: "beneficiaries", withExtension: "json") else {
            throw NSError(domain: "BeneficiaryService", code: 404,
                          userInfo: [NSLocalizedDescriptionKey: "beneficiaries.json not found"])
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([Beneficiary].self, from: data)
    }

    func filter(_ beneficiaries: [Beneficiary], query: String) -> [Beneficiary] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return beneficiaries }
        return beneficiaries.filter {
            $0.fullName.localizedCaseInsensitiveContains(query) ||
            $0.bankName.localizedCaseInsensitiveContains(query) ||
            $0.accountNumber.contains(query)
        }
    }
}
