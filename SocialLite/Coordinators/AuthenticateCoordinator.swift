//
//  AuthenticateCoordinator.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 2/4/2564 BE.
//

import Foundation
import XCoordinator

final class AuthenticateCoordinator: NavigationCoordinator<AuthenticateRoute> {
    override func prepareTransition(for route: RouteType) -> TransitionType {
        switch route {
        case .login:
            let viewModel = LoginViewModel(with: weakRouter)
            let controller = LoginViewController.newInstance(with: viewModel)
            return .push(controller)
        case .register:
            let viewModel = RegisterViewModel(with: weakRouter)
            let controller = RegisterViewController.newInstance(with: viewModel)
            return .push(controller)
        case .close:
            return .dismissToRoot()
        }
    }
}
