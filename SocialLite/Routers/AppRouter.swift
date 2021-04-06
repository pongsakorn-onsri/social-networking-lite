//
//  AppRouter.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 2/4/2564 BE.
//

import Foundation
import XCoordinator

public enum AppRoute: Route {
    case feed
    case timeline
    case post
    case authenticate
    case signout
    case alert(Error)
    case dismiss
}
