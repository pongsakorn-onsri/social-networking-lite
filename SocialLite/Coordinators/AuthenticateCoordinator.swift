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
        }
    }
}
