//
//  SceneDelegate.swift
//  SocialLite
//
//  Created by pongsakorn on 1/4/2564 BE.
//

import UIKit
import XCoordinator
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    lazy var router = AppCoordinator().strongRouter

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        FirebaseApp.configure()
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let newWindow = UIWindow(windowScene: windowScene)
        self.window = newWindow
        router.setRoot(for: newWindow)
    }

}
