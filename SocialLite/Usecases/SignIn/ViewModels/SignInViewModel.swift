//
//  LoginViewModel.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 2/4/2564 BE.
//

import Foundation
import XCoordinator
import RxSwift
import RxCocoa
import GoogleSignIn
import Firebase

final class SignInViewModel: NSObject, ViewModelProtocol {
    typealias RouteType = AuthenticateRoute
    var router: WeakRouter<RouteType>
    var errorSubject: PublishSubject<Error> = PublishSubject()
    var disposeBag: DisposeBag = DisposeBag()
    
    required init(with router: WeakRouter<AuthenticateRoute>) {
        self.router = router
    }
    
    struct Input {
        let email: Observable<String>
        let password: Observable<String>
        let signInTapped: Observable<Void>
        let signUpTapped: Observable<Void>
    }
    
    struct Output {
        let emailError: Driver<Error?>
        let passwordError: Driver<Error?>
    }
    
    let inputEmail: BehaviorRelay<String> = BehaviorRelay(value: "")
    let inputPassword: BehaviorRelay<String> = BehaviorRelay(value: "")
    let outputEmailError: PublishSubject<Error?> = PublishSubject()
    let outputPasswordError: PublishSubject<Error?> = PublishSubject()
    let signInErrorSubject: PublishSubject<Error?> = PublishSubject()
    
    func transform(input: Input) -> Output {
        input.email
            .bind(to: inputEmail)
            .disposed(by: disposeBag)
        input.password
            .bind(to: inputPassword)
            .disposed(by: disposeBag)
        
        input.signInTapped
            .map { _ in (self.inputEmail.value, self.inputPassword.value) }
            .filter(validate)
            .subscribe(onNext: { [weak self](email, password) in
                self?.signIn(with: email, password: password)
            })
            .disposed(by: disposeBag)
        
        input.signUpTapped
            .subscribe(onNext: { [weak self]_ in
                self?.router.trigger(.signup)
            })
            .disposed(by: disposeBag)
        
        signInErrorSubject
            .subscribe(onNext: { [weak self]error in
                if let error = error {
                    self?.router.trigger(.alert(error))
                }
            })
            .disposed(by: disposeBag)
        
        return Output(
            emailError: outputEmailError.asDriver(onErrorJustReturn: nil),
            passwordError: outputPasswordError.asDriver(onErrorJustReturn: nil)
        )
    }
    
    func signIn(with credential: AuthCredential) {
        UserManager.shared.signIn(with: credential)
            .subscribe(onSuccess: { [weak self]_ in
                self?.outputEmailError.onNext(nil)
                self?.outputPasswordError.onNext(nil)
                self?.signInErrorSubject.onNext(nil)
                self?.router.trigger(.close)
            }, onError: { [weak self]error in
                self?.signInErrorSubject.onNext(error)
            })
            .disposed(by: disposeBag)
    }
    
    func signIn(with email: String, password: String) {
        UserManager.shared.signIn(with: email, password: password)
            .subscribe(onSuccess: { [weak self]_ in
                self?.outputEmailError.onNext(nil)
                self?.outputPasswordError.onNext(nil)
                self?.signInErrorSubject.onNext(nil)
                self?.router.trigger(.close)
            }, onError: { [weak self]error in
                self?.signInErrorSubject.onNext(error)
            })
            .disposed(by: disposeBag)
    }
    
    private func validate(_ email: String, _ password: String) -> Bool {
        let emailValid = !email.trimmingCharacters(in: .whitespaces).isEmpty
        outputEmailError.onNext(emailValid ? nil : SignInError.message("Please input email account."))
        
        let passwordValid = !password.trimmingCharacters(in: .whitespaces).isEmpty
        outputPasswordError.onNext(passwordValid ? nil : SignInError.message("Please input your password."))
        return emailValid && passwordValid
    }
}
