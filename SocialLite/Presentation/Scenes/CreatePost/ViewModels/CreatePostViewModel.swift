//
//  CreatePostViewModel.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 3/4/2564 BE.
//

import UIKit
import RxSwift
import RxCocoa
import XCoordinator
import MGArchitecture
import Resolver

struct CreatePostViewModel {
    let router: WeakRouter<AppRoute>
    let user: User
    let delegate: PublishSubject<Post>
    @Injected var useCase: CreatePostUseCaseType
}

extension CreatePostViewModel: ViewModel {

    struct Input {
        let textInput: Driver<String>
        let closeTapped: Driver<Void>
        let createTapped: Driver<Void>
    }
    
    struct Output {
        @Property var countingText: String = "0 / 1024"
        @Property var isLoading: Bool = false
        @Property var validateMessage: String = ""
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
        
        input.closeTapped
            .drive(onNext: {
                router.trigger(.dismiss)
            })
            .disposed(by: disposeBag)
        
        let textInputCount = input.textInput
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).count }
        
        textInputCount
            .map { "\($0) / 1024" }
            .drive(output.$countingText)
            .disposed(by: disposeBag)
        
        let createPostSubject = input.createTapped
            .withLatestFrom(input.textInput)
            .map { (content) -> Post in
                Post(userId: user.uid,
                     displayName: user.postDisplayName,
                     content: content,
                     timestamp: Date())
            }
        
        let validation = createPostSubject
            .map(useCase.validate(_:))
            
        validation
            .map(\.firstMessage)
            .drive(output.$validateMessage)
            .disposed(by: disposeBag)
        
        createPostSubject
            .withLatestFrom(Driver.and(validation.map { $0.isValid }, isLoading.not()))
            .filter { $0 }
            .withLatestFrom(createPostSubject)
            .flatMapLatest { (post) in
                useCase.createPost(CreatePostDto(post: post))
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .drive(onNext: { newPost in
                delegate.onNext(newPost)
                router.trigger(.dismiss)
            })
            .disposed(by: disposeBag)
        
        return output
    }
}
