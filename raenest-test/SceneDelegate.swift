//
//  SceneDelegate.swift
//  raenest-test
//
//  Created by Itunu Raimi on 17/08/2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        window.backgroundColor = .systemBackground

        let validationService: ValidationService
        do {
            validationService = try ValidationService()
        } catch {
            let defaultRules = ValidationRules(minAmount: 10, maxAmount: 20000, allowedCurrencies: ["USD", "NGN", "GBP", "EUR"])
            validationService = ValidationService(rules: defaultRules)
        }

        let viewModel = SendMoneyViewModel(validationService: validationService)
        let rootVC = SendMoneyViewController(viewModel: viewModel)
        let navigationVC = UINavigationController(rootViewController: rootVC)

        window.rootViewController = navigationVC

        self.window = window
        window.makeKeyAndVisible()
    }
}
