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
import MGArchitecture
import Resolver

struct SignUpViewModel {
    var router: WeakRouter<AuthenticateRoute>
    @Injected var useCase: SignUpUseCaseType
    let delegate: PublishSubject<User>
}

extension SignUpViewModel: ViewModel {
    struct Input {
        let email: Driver<String>
        let password: Driver<String>
        let confirmPassword: Driver<String>
        let submitTrigger: Driver<Void>
    }
    
    struct Output {
        @Property var emailValidationMessage = ""
        @Property var passwordValidationMessage = ""
        @Property var confirmPasswordValidationMessage = ""
        @Property var isLoading = false
    }
    
    enum ValidateType {
        case email
        case password
        case confirmPassword
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
        
        let emailValidation = input.submitTrigger
            .withLatestFrom(input.email)
            .map(useCase.validateEmail(_:))
        
        emailValidation
            .map { $0.firstMessage }
            .drive(output.$emailValidationMessage)
            .disposed(by: disposeBag)
        
        let passwordValidation = input.submitTrigger
            .withLatestFrom(input.password)
            .map(useCase.validatePassword(_:))
        
        passwordValidation
            .map { $0.firstMessage }
            .drive(output.$passwordValidationMessage)
            .disposed(by: disposeBag)
        
        let confirmPasswordValidation = input.submitTrigger
            .withLatestFrom(input.confirmPassword)
            .withLatestFrom(input.password) { ($0, $1) }
            .map {
                useCase.validateConfirmPassword($0.0, $0.1)
            }
        
        confirmPasswordValidation
            .map { $0.firstMessage }
            .drive(output.$confirmPasswordValidationMessage)
            .disposed(by: disposeBag)
        
        let validation = Driver.and(
            emailValidation.map { $0.isValid },
            passwordValidation.map { $0.isValid },
            confirmPasswordValidation.map { $0.isValid }
        )
        .startWith(true)

        input.submitTrigger
            .withLatestFrom(Driver.merge(validation, isLoading.not()))
            .filter { $0 }
            .withLatestFrom(Driver.combineLatest(input.email, input.password))
            .flatMapLatest { (email, password) -> Driver<User> in
                let dto = SignUpDto(email: email, password: password, confirmPassword: password)
                return useCase.signUp(dto: dto)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .drive(onNext: { user in
                delegate.onNext(user)
                router.trigger(.close)
            })
            .disposed(by: disposeBag)

        return output
    }
    
}
