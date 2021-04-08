//
//  AuthenticateCoordinator.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 2/4/2564 BE.
//

import Foundation
import XCoordinator
import MaterialComponents.MaterialDialogs

final class AuthenticateCoordinator: NavigationCoordinator<AuthenticateRoute> {
    override func prepareTransition(for route: RouteType) -> TransitionType {
        switch route {
        case .signin:
            let viewModel = SignInViewModel(with: weakRouter)
            let controller = SignInViewController.newInstance(with: viewModel)
            return .push(controller)
        case .signup:
            let viewModel = SignUpViewModel(with: weakRouter)
            let controller = SignUpViewController.newInstance(with: viewModel)
            return .push(controller)
        case .close:
            return .dismissToRoot()
        case let .alert(error):
            let alertController = MDCAlertController(title: "Error!",
                                                     message: error.localizedDescription)
            let actionConfirm = MDCAlertAction(title: "Confirm", emphasis: .high, handler: nil)
            alertController.addAction(actionConfirm)
            alertController.applyTheme(withScheme: containerScheme)
            return .present(alertController)
        }
    }
}
