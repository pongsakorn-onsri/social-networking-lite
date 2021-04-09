//
//  AppRouter.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 2/4/2564 BE.
//

import Foundation
import XCoordinator
import RxSwift
import RxCocoa

public enum AppRoute: Route {
    case feed
    case timeline
    case post(delegate: PublishSubject<Post>)
    case authenticate(delegate: PublishSubject<User>)
    case signout(delegate: PublishSubject<Void>)
    case alert(Error)
    case deleteAlert(post: Post, delegate: PublishSubject<Post>)
    case dismiss
}
