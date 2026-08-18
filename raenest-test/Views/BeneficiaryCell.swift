//
//  BeneficiaryCell.swift
//  raenest-test
//
//  Created by Itunu Raimi on 17/08/2026.
//

import UIKit

final class BeneficiaryCell: UITableViewCell {

    static let reuseID = "BeneficiaryCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.cardBackground
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let avatarLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = Theme.primary
        label.layer.cornerRadius = 20
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = Theme.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let detailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = Theme.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let checkmark: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        imageView.tintColor = Theme.primary
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(containerView)

        let stack = UIStackView(arrangedSubviews: [nameLabel, detailLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(avatarLabel)
        containerView.addSubview(stack)
        containerView.addSubview(checkmark)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            avatarLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            avatarLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            avatarLabel.widthAnchor.constraint(equalToConstant: 40),
            avatarLabel.heightAnchor.constraint(equalToConstant: 40),

            stack.leadingAnchor.constraint(equalTo: avatarLabel.trailingAnchor, constant: 12),
            stack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: checkmark.leadingAnchor, constant: -8),

            checkmark.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            checkmark.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            checkmark.widthAnchor.constraint(equalToConstant: 24),
            checkmark.heightAnchor.constraint(equalToConstant: 24),

            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 64)
        ])
    }

    func configure(with beneficiary: Beneficiary, isSelected: Bool) {
        nameLabel.text = beneficiary.fullName
        detailLabel.text = "\(beneficiary.bankName) · \(beneficiary.maskedAccount)"
        avatarLabel.text = beneficiary.initials
        checkmark.isHidden = !isSelected
        containerView.layer.borderWidth = isSelected ? 2 : 0
        containerView.layer.borderColor = isSelected ? Theme.primary?.cgColor : nil
    }
}
