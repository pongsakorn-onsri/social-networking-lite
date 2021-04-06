//
//  AppCoordinator.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 2/4/2564 BE.
//

import Foundation
import XCoordinator
import MaterialComponents
import FirebaseFirestore

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
            let controller = CreatePostViewController.newInstance(with: viewModel)
            return .present(controller)
        case .signout:
            let alertController = MDCAlertController(title: "Are you sure to sign out ?",
                                                     message: nil)
            let actionSignOut = MDCAlertAction(title: "Sign out", emphasis: .high) { _ in
                UserManager.shared.signOut()
            }
            let actionCancel = MDCAlertAction(title: "Cancel", emphasis: .low, handler: nil)
            
            alertController.addAction(actionSignOut)
            alertController.addAction(actionCancel)
            alertController.applyTheme(withScheme: containerScheme)
            
            return .present(alertController)
        case let .alert(error):
            let alertController = MDCAlertController(title: "Error!",
                                                     message: error.localizedDescription)
            let actionConfirm = MDCAlertAction(title: "Confirm", emphasis: .high, handler: nil)
            alertController.addAction(actionConfirm)
            alertController.applyTheme(withScheme: containerScheme)
            return .present(alertController)
        case let .delete(post, observer):
            let alertController = MDCAlertController(title: "Are you sure to delete?",
                                                     message: nil)
            let actionConfirm = MDCAlertAction(title: "Confirm", emphasis: .high) { _ in
                observer.onNext(post)
            }
            let actionCancel = MDCAlertAction(title: "Cancel", emphasis: .low, handler: nil)
            alertController.addAction(actionConfirm)
            alertController.addAction(actionCancel)
            alertController.applyTheme(withScheme: containerScheme)
            return .present(alertController)
            
        case .dismiss:
            return .dismiss()
        }
        
    }
}
