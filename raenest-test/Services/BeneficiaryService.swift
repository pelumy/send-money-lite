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
        let trimmed = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !trimmed.isEmpty else { return beneficiaries }

        let matches = beneficiaries.filter {
            $0.fullName.localizedCaseInsensitiveContains(trimmed) ||
            $0.bankName.localizedCaseInsensitiveContains(trimmed) ||
            $0.accountNumber.contains(trimmed)
        }

        return matches.sorted { lhs, rhs in
            let lhsName = lhs.fullName.lowercased()
            let rhsName = rhs.fullName.lowercased()

            // Full name starts with query
            let lhsNamePrefix = lhsName.hasPrefix(trimmed)
            let rhsNamePrefix = rhsName.hasPrefix(trimmed)
            if lhsNamePrefix != rhsNamePrefix { return lhsNamePrefix }

            // Any word in full name starts with query (e.g. "Chen" in "David Chen")
            let lhsWordMatch = lhsName.split(separator: " ").contains { $0.hasPrefix(trimmed) }
            let rhsWordMatch = rhsName.split(separator: " ").contains { $0.hasPrefix(trimmed) }
            if lhsWordMatch != rhsWordMatch { return lhsWordMatch }

            // 3. Bank name starts with query (e.g. "Chase Bank")
            let lhsBankPrefix = lhs.bankName.lowercased().hasPrefix(trimmed)
            let rhsBankPrefix = rhs.bankName.lowercased().hasPrefix(trimmed)
            if lhsBankPrefix != rhsBankPrefix { return lhsBankPrefix }

            // Fallback: alphabetical
            return lhs.fullName < rhs.fullName
        }
    }
}
