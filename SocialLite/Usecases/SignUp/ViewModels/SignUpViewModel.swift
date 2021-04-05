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
    var outputEmail: PublishSubject<Error?> = PublishSubject()
    var outputPassword: PublishSubject<Error?> = PublishSubject()
    var outputConfirmPassword: PublishSubject<Error?> = PublishSubject()
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
        
        let inputForms = Observable.combineLatest(inputEmail, inputPassword, inputConfirmPassword)
        
        input.submitTapped
            .withLatestFrom(inputForms)
            .flatMap(validateAll)
            .filter { success in success }
            .withLatestFrom(inputForms)
            .subscribe(onNext: { [weak self](email, password, _) in
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
            emailError: outputEmail.asDriver(onErrorJustReturn: nil),
            passwordError: outputPassword.asDriver(onErrorJustReturn: nil),
            confirmPasswordError: outputConfirmPassword.asDriver(onErrorJustReturn: nil)
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
    
    private func validateAll(_ email: String, _ password: String, _ confirmPassword: String) -> Single<Bool> {
        return Single.create { (observer) -> Disposable in
            
            let validateEmail = self.validate(email, type: .email)
            self.outputEmail.onNext(validateEmail)
            
            let validatePassword = self.validate(password, type: .password)
            self.outputPassword.onNext(validatePassword)
            
            let validateConfirmPassword = self.validate(confirmPassword, type: .confirmPassword)
            self.outputConfirmPassword.onNext(validateConfirmPassword)
            
            observer(.success(validateEmail == nil && validatePassword == nil && validateConfirmPassword == nil))
            
            return Disposables.create()
        }
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
