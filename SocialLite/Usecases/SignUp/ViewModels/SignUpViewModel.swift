//
//  SignUpViewModel.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 2/4/2564 BE.
//

import UIKit
import RxSwift
import RxCocoa
import XCoordinator

class SignUpViewModel: NSObject, ViewModelProtocol {
    typealias RouteType = AuthenticateRoute
    var router: WeakRouter<RouteType>
    var disposeBag: DisposeBag = DisposeBag()
    
    required init(with router: WeakRouter<AuthenticateRoute>) {
        self.router = router
    }
    
    struct Input {
        let email: Observable<String>
        let password: Observable<String>
        let confirmPassword: Observable<String>
        let submitTapped: Observable<Void>
    }
    
    struct Output {
        let emailError: Driver<Error?>
        let passwordError: Driver<Error?>
        let confirmPasswordError: Driver<Error?>
    }
    
    enum ValidateType {
        case email
        case password
        case confirmPassword
    }
    
    var inputEmail: BehaviorRelay<String> = BehaviorRelay(value: "")
    var inputPassword: BehaviorRelay<String> = BehaviorRelay(value: "")
    var inputConfirmPassword: BehaviorRelay<String> = BehaviorRelay(value: "")
    var signUpErrorSubject: PublishSubject<Error> = PublishSubject()
    
    func transform(input: Input) -> Output {
        
        input.email
            .bind(to: inputEmail)
            .disposed(by: disposeBag)
        
        input.password
            .bind(to: inputPassword)
            .disposed(by: disposeBag)
        
        input.confirmPassword
            .bind(to: inputConfirmPassword)
            .disposed(by: disposeBag)
        
        let validateEmail = input.email
            .map { self.validate($0, type: .email) }
            .asObservable()
        
        let validatePassword = input.password
            .map { self.validate($0, type: .password) }
            .asObservable()
        
        let validateConfirmPassword = input.confirmPassword
            .map { self.validate($0, type: .confirmPassword) }
            .asObservable()
        
        input.submitTapped
            .flatMap { _ in
                Observable.zip(validateEmail, validatePassword, validateConfirmPassword)
                    .filter { errors -> Bool in
                        errors.0 == nil && errors.1 == nil && errors.2 == nil
                    }
            }
            .map { _ in (self.inputEmail.value, self.inputPassword.value) }
            .subscribe(onNext: { [weak self](email, password) in
                self?.signUp(with: email, password: password)
            }, onError: { [weak self](error) in
                self?.signUpErrorSubject.onNext(error)
            })
            .disposed(by: disposeBag)
        
        signUpErrorSubject
            .subscribe(onNext: { [weak self]error in
                self?.router.trigger(.alert(error))
            })
            .disposed(by: disposeBag)
        
        return Output(
            emailError: validateEmail.asDriver(onErrorJustReturn: nil),
            passwordError: validatePassword.asDriver(onErrorJustReturn: nil),
            confirmPasswordError: validateConfirmPassword.asDriver(onErrorJustReturn: nil)
        )
    }
    
    private func signUp(with email: String, password: String) {
        UserManager.shared.signUp(with: email, password: password)
            .subscribe(onSuccess: { [weak self]_ in
                self?.router.trigger(.close)
            }, onError: { [weak self]error in
                self?.signUpErrorSubject.onNext(error)
            })
            .disposed(by: disposeBag)
    }
    
    private func validate(_ value: String, type: ValidateType) -> Error? {
        switch type {
        case .email where value.isEmpty:
            return SignInError.message("Please input your email address.")
        case .email:
            let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
            if value.range(of: emailPattern, options: .regularExpression, range: nil, locale: nil) == nil {
                return SignInError.message("Your email address incorrect format.")
            }
            return nil
        case .password:
            let checkValue = value.trimmingCharacters(in: .whitespaces)
            if checkValue.isEmpty {
                return SignInError.message("Please input your password.")
            } else if checkValue.count < 8 {
                return SignInError.message("Password is too short")
            }
            return nil
        case .confirmPassword:
            let checkValue = value.trimmingCharacters(in: .whitespaces)
            if checkValue.isEmpty {
                return SignInError.message("Please input your confirm password.")
            } else if checkValue.count < 8 {
                return SignInError.message("Password is too short")
            } else if checkValue != inputPassword.value {
                return SignInError.message("Confirm password should be match password")
            }
            return nil
        }
    }
}
