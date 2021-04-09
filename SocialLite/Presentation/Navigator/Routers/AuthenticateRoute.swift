//
//  AuthenticateRoute.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 2/4/2564 BE.
//

import Foundation
import XCoordinator
import RxSwift

public enum AuthenticateRoute: Route {
    case signin(delegate: PublishSubject<User>)
    case signup(delegate: PublishSubject<User>)
    case close
    case alert(Error)
}
