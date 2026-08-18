//
//  SendMoneyViewController.swift
//  raenest-test
//
//  Created by Itunu Raimi on 17/08/2026.
//

import UIKit

final class SendMoneyViewController: UIViewController {

    private let viewModel: SendMoneyViewModel

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Send Money"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = Theme.textPrimary
        return label
    }()

    private let amountField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter amount"
        textField.font = .systemFont(ofSize: 20, weight: .medium)
        textField.keyboardType = .decimalPad
        textField.borderStyle = .none
        textField.backgroundColor = Theme.cardBackground
        textField.layer.cornerRadius = 12
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.rightViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 52).isActive = true
        return textField
    }()

    private let amountErrorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = Theme.error
        label.isHidden = true
        return label
    }()

    private let limitsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = Theme.textSecondary
        return label
    }()

    private let currencySegment: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.selectedSegmentTintColor = Theme.primary
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.setTitleTextAttributes([.foregroundColor: Theme.textPrimary], for: .normal)
        return segmentedControl
    }()

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search beneficiaries"
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.5), for: .disabled)
        button.backgroundColor = Theme.primary
        button.layer.cornerRadius = 14
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 52).isActive = true
        button.isEnabled = false
        return button
    }()

    init(viewModel: SendMoneyViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardDismissal()
        setupBindings()
        viewModel.loadBeneficiaries()
    }
    
    private func setupUI() {
        view.backgroundColor = Theme.background
        navigationController?.navigationBar.prefersLargeTitles = false

        setupCurrencySegment()

        limitsLabel.text = viewModel.limitsHint

        let amountSection = makeSection("Amount", views: [amountField, amountErrorLabel, limitsLabel])
        let currencySection = makeSection("Currency", views: [currencySegment])
        let beneficiarySection = makeSection("Select Beneficiary", views: [searchBar])

        let topStack = UIStackView(arrangedSubviews: [
            headerLabel,
            amountSection,
            currencySection,
            beneficiarySection
        ])
        topStack.axis = .vertical
        topStack.spacing = 16
        topStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(topStack)
        view.addSubview(tableView)
        view.addSubview(continueButton)

        tableView.register(BeneficiaryCell.self, forCellReuseIdentifier: BeneficiaryCell.reuseID)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag

        NSLayoutConstraint.activate([
            topStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            topStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            topStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -12),

            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }

    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setupCurrencySegment() {
        for (i, currency) in viewModel.currencies.enumerated() {
            currencySegment.insertSegment(withTitle: currency, at: i, animated: false)
        }
        if let idx = viewModel.currencies.firstIndex(of: viewModel.selectedCurrency) {
            currencySegment.selectedSegmentIndex = idx
        }
    }

    private func makeSection(_ title: String, views: [UIView]) -> UIStackView {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = Theme.textSecondary
        let stack = UIStackView(arrangedSubviews: [label] + views)
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }

    private func setupBindings() {
        amountField.addTarget(self, action: #selector(amountChanged), for: .editingChanged)
        currencySegment.addTarget(self, action: #selector(currencyChanged), for: .valueChanged)
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        searchBar.delegate = self

        viewModel.onUpdate = { [weak self] in
            self?.updateUI()
        }
    }

    @objc private func amountChanged() {
        viewModel.setAmount(amountField.text ?? "")
    }

    @objc private func currencyChanged() {
        let idx = currencySegment.selectedSegmentIndex
        if idx >= 0, idx < viewModel.currencies.count {
            viewModel.selectCurrency(viewModel.currencies[idx])
        }
    }

    @objc private func continueTapped() {
        guard let amount = viewModel.parsedAmount,
              let beneficiary = viewModel.selectedBeneficiary else { return }

        let confirmationViewModel = ConfirmationViewModel(
            amount: amount,
            currency: viewModel.selectedCurrency,
            beneficiary: beneficiary
        )
        let vc = ConfirmationViewController(viewModel: confirmationViewModel)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func updateUI() {
        continueButton.isEnabled = viewModel.isContinueEnabled
        continueButton.alpha = viewModel.isContinueEnabled ? 1.0 : 0.5

        if let error = viewModel.amountError {
            amountErrorLabel.text = error
            amountErrorLabel.isHidden = false
        } else {
            amountErrorLabel.isHidden = true
        }

        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource / Delegate
extension SendMoneyViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.filteredBeneficiaries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: BeneficiaryCell.reuseID,
            for: indexPath
        ) as? BeneficiaryCell else {
            return UITableViewCell()
        }
        let beneficiary = viewModel.filteredBeneficiaries[indexPath.row]
        cell.configure(with: beneficiary, isSelected: beneficiary == viewModel.selectedBeneficiary)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectBeneficiary(viewModel.filteredBeneficiaries[indexPath.row])
    }
}

// MARK: - UISearchBarDelegate
extension SendMoneyViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.search(searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
