//
//  ValidationRules.swift
//  raenest-test
//
//  Created by Itunu Raimi on 17/08/2026.
//

import Foundation

struct ValidationRules: Codable {
    let minAmount: Double
    let maxAmount: Double
    let allowedCurrencies: [String]

    enum CodingKeys: String, CodingKey {
        case minAmount = "min_amount"
        case maxAmount = "max_amount"
        case allowedCurrencies = "allowed_currencies"
    }
}
