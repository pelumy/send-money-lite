//
//  Beneficiary.swift
//  raenest-test
//
//  Created by Itunu Raimi on 17/08/2026.
//

import Foundation

struct Beneficiary: Codable, Equatable {
    let id: String
    let fullName: String
    let bankName: String
    let accountNumber: String
    let currency: String

    var initials: String {
        let parts = fullName.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(fullName.prefix(2)).uppercased()
    }

    var maskedAccount: String {
        guard accountNumber.count > 4 else { return accountNumber }
        return "•••• \(accountNumber.suffix(4))"
    }
}
