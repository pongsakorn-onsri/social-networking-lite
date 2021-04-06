//
//  AppCoordinator.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 2/4/2564 BE.
//

import Foundation
import XCoordinator
import MaterialComponents

final class AppCoordinator: NavigationCoordinator<AppRoute> {
    init() {
        super.init(initialRoute: .feed)
    }
    
    private var authenCoordinator: AuthenticateCoordinator?
    
    fileprivate func authTransition(_ route: AuthenticateRoute = .signin) -> NavigationTransition {
        let coor = AuthenticateCoordinator(initialRoute: route)
        coor.rootViewController.modalPresentationStyle = .fullScreen
        authenCoordinator = coor
        return .present(coor)
    }
    
    override func prepareTransition(for route: RouteType) -> TransitionType {
        switch route {
        case .authenticate:
            return authTransition(.signin)
        case .feed:
            let viewModel = FeedViewModel(with: weakRouter)
            let controller = FeedViewController.newInstance(with: viewModel)
            return .set([controller])
        case .timeline:
            return .none()
        case .post:
            let viewModel = CreatePostViewModel(with: weakRouter)
            viewModel.service = CreatePostService(user: UserManager.shared.currentUser)
            let controller = CreatePostViewController.newInstance(with: viewModel)
            return .present(controller)
        case .signout:
            let alertController = UIAlertController(title: "Are you sure to sign out ?", message: nil, preferredStyle: .actionSheet)
            let actionConfirm = UIAlertAction(title: "Sign out", style: .destructive) { _ in
                UserManager.shared.signOut()
            }
            let actionCancel = UIAlertAction(title: "Cancel", style: .default) { _ in
                
            }
            alertController.addAction(actionConfirm)
            alertController.addAction(actionCancel)
            return .present(alertController)
        case let .alert(error):
            let alertController = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
            let actionConfirm = UIAlertAction(title: "Confirm", style: .default, handler: nil)
            alertController.addAction(actionConfirm)
            return .present(alertController)
        case .dismiss:
            return .dismiss()
        }
        
    }
}
