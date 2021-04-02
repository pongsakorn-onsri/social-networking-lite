//
//  LoginViewModel.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 2/4/2564 BE.
//

import Foundation
import RxSwift
import XCoordinator
import GoogleSignIn
import FirebaseAuth

final class LoginViewModel: NSObject, ViewModelProtocol {
    typealias RouteType = AuthenticateRoute
    var router: WeakRouter<RouteType>
    var disposeBag: DisposeBag = DisposeBag()
    
    required init(with router: WeakRouter<AuthenticateRoute>) {
        self.router = router
    }
    
    func routeToRegister() {
        router.trigger(.register)
    }
    
    func signIn(with credential: AuthCredential) {
        
    }
}
