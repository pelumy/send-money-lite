//
//  ConfirmationViewController.swift
//  raenest-test
//
//  Created by Itunu Raimi on 17/08/2026.
//

import UIKit

final class ConfirmationViewController: UIViewController {

    private let viewModel: ConfirmationViewModel

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.cardBackground
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 36, weight: .bold)
        label.textColor = Theme.textPrimary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let sendToLabel: UILabel = {
        let label = UILabel()
        label.text = "Sending to"
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = Theme.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = Theme.textPrimary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let bankLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = Theme.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let statusCard: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Theme.primary
        button.layer.cornerRadius = 14
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 52).isActive = true
        return button
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()

    init(viewModel: ConfirmationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }

    private func setupUI() {
        view.backgroundColor = Theme.background
        title = "Confirm Transfer"

        amountLabel.text = viewModel.formattedAmount
        nameLabel.text = viewModel.beneficiary.fullName
        bankLabel.text = "\(viewModel.beneficiary.bankName) • \(viewModel.beneficiary.maskedAccount)"
        confirmButton.setTitle("Confirm with \(viewModel.biometryName)", for: .normal)

        view.addSubview(cardView)
        cardView.addSubview(amountLabel)
        cardView.addSubview(sendToLabel)
        cardView.addSubview(nameLabel)
        cardView.addSubview(bankLabel)

        view.addSubview(statusCard)
        statusCard.addSubview(statusLabel)

        view.addSubview(confirmButton)
        confirmButton.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            amountLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
            amountLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            amountLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            sendToLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 20),
            sendToLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            sendToLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            nameLabel.topAnchor.constraint(equalTo: sendToLabel.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            bankLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            bankLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            bankLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            bankLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -24),

            statusCard.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 24),
            statusCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            statusLabel.topAnchor.constraint(equalTo: statusCard.topAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: statusCard.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: statusCard.trailingAnchor, constant: -16),
            statusLabel.bottomAnchor.constraint(equalTo: statusCard.bottomAnchor, constant: -16),

            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),

            activityIndicator.centerXAnchor.constraint(equalTo: confirmButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: confirmButton.centerYAnchor)
        ])
    }

    private func setupBindings() {
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)

        viewModel.onStateChange = { [weak self] state in
            DispatchQueue.main.async {
                self?.updateUI(for: state)
            }
        }
    }

    @objc private func confirmTapped() {
        Task {
            await viewModel.confirmPayment()
        }
    }

    private func updateUI(for state: ConfirmationState) {
        switch state {
        case .idle:
            confirmButton.isEnabled = true
            confirmButton.setTitle("Confirm with \(viewModel.biometryName)", for: .normal)
            activityIndicator.stopAnimating()
            statusCard.isHidden = true

        case .loading:
            confirmButton.isEnabled = false
            confirmButton.setTitle("", for: .normal)
            activityIndicator.startAnimating()
            statusCard.isHidden = true

        case .success(let message):
            confirmButton.isEnabled = true
            confirmButton.setTitle("Done", for: .normal)
            confirmButton.removeTarget(nil, action: nil, for: .allEvents)
            confirmButton.addTarget(self, action: #selector(dismissFlow), for: .touchUpInside)
            activityIndicator.stopAnimating()

            statusCard.isHidden = false
            statusCard.backgroundColor = Theme.success.withAlphaComponent(0.15)
            statusLabel.textColor = Theme.success
            statusLabel.text = "✓ Success\n\n\(message)"

        case .error(let error):
            confirmButton.isEnabled = true
            confirmButton.setTitle("Retry Transfer", for: .normal)
            activityIndicator.stopAnimating()

            statusCard.isHidden = false
            statusCard.backgroundColor = Theme.error.withAlphaComponent(0.15)
            statusLabel.textColor = Theme.error
            statusLabel.text = "⚠️ Error\n\n\(error)"
        }
    }

    @objc private func dismissFlow() {
        navigationController?.popToRootViewController(animated: true)
    }
}
