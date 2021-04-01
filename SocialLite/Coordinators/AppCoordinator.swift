//
//  AppCoordinator.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 2/4/2564 BE.
//

import Foundation
import XCoordinator

final class AppCoordinator: NavigationCoordinator<AppRoute> {
    init() {
        super.init(initialRoute: .launch)
    }
    
    fileprivate func authTransition(_ route: AuthenticateRoute = .login) -> NavigationTransition {
        let coor = AuthenticateCoordinator(initialRoute: route)
        coor.rootViewController.modalPresentationStyle = .fullScreen
        return .present(coor)
    }
    
    override func prepareTransition(for route: RouteType) -> TransitionType {
        switch route {
        case .authenticate:
            return authTransition(.login)
        case .launch:
            var routes = [AppRoute.feed]
            if UserManager.shared.user == nil {
                routes.append(.authenticate)
            }
            return .multiple(routes.map { prepareTransition(for: $0) })
        case .feed:
            let viewModel = FeedViewModel(with: weakRouter)
            let controller = FeedViewController.newInstance(with: viewModel)
            return .set([controller])
        case .timeline:
            return .none()
        case .post:
            return .none()
        }
    }
}
