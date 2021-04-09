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
import Resolver
import MGArchitecture

struct SignInViewModel {
    let router: WeakRouter<AuthenticateRoute>
    @Injected var useCase: SignInUseCaseType
    let delegate: PublishSubject<User>
}

extension SignInViewModel: ViewModel {
    struct Input {
        let email: Driver<String>
        let password: Driver<String>
        let signInTapped: Driver<Void>
        let signUpTapped: Driver<Void>
        let signInGoogle: Driver<AuthCredential>
    }
    
    struct Output {
        @Property var emailValidationMessage = ""
        @Property var passwordValidationMessage = ""
        @Property var isLoading = false
    }
    
    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()
        
        errorTracker
            .drive(onNext: { error in
                router.trigger(.alert(error))
            })
            .disposed(by: disposeBag)
        
        let isLoading = activityIndicator.asDriver()
        
        isLoading
            .drive(output.$isLoading)
            .disposed(by: disposeBag)
        
        let emailValidation = Driver.combineLatest(input.email, input.signInTapped)
            .map { $0.0 }
            .map(useCase.validateEmail(_:))
        
        emailValidation
            .map { $0.message }
            .drive(output.$emailValidationMessage)
            .disposed(by: disposeBag)
        
        let passwordValidation = Driver.combineLatest(input.password, input.signInTapped)
            .map { $0.0 }
            .map(useCase.validatePassword(_:))
        
        passwordValidation
            .map { $0.message }
            .drive(output.$passwordValidationMessage)
            .disposed(by: disposeBag)
        
        let validation = Driver.and(
            emailValidation.map { $0.isValid },
            passwordValidation.map { $0.isValid }
        )
        .startWith(true)
        
        input.signInTapped
            .withLatestFrom(Driver.merge(validation, isLoading.not()))
            .filter { $0 }
            .withLatestFrom(Driver.combineLatest(input.email, input.password))
            .flatMapLatest { (email, password) -> Driver<User> in
                self.useCase.signIn(dto: SignInDto(email: email, password: password))
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .drive(onNext: { user in
                delegate.onNext(user)
                router.trigger(.close)
            })
            .disposed(by: disposeBag)
        
        input.signInGoogle
            .flatMapLatest { (credential) -> Driver<User> in
                self.useCase.signIn(with: credential)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .drive(onNext: { user in
                router.trigger(.close)
            })
            .disposed(by: disposeBag)
        
        input.signUpTapped
            .drive(onNext: {
                router.trigger(.signup(delegate: delegate))
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
}
