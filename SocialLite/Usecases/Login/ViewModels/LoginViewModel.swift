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
    var errorSubject: PublishSubject<Error> = PublishSubject()
    var disposeBag: DisposeBag = DisposeBag()
    
    required init(with router: WeakRouter<AuthenticateRoute>) {
        self.router = router
    }
    
    func signIn(with credential: AuthCredential) {
        UserManager.shared.signIn(with: credential)
            .subscribe(onSuccess: { [weak self]_ in
                self?.router.trigger(.close)
            }, onError: { [weak self]error in
                self?.errorSubject.onNext(error)
            })
            .disposed(by: disposeBag)
    }
}
