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

final class CreatePostViewModel: BaseViewModel {

    struct Input {
        let closeTapped: Observable<Void>
        let createTapped: Observable<Void>
        let textInput: Observable<String>
    }
    
    struct Output {
        let countingText: Observable<String>
        let isPosting: Driver<Bool>
        let validate: Driver<Error?>
    }
    
    lazy var service: CreatePostUseCase = CreatePostService()
    let isPostingBehavior: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    let createPostErrorPublish: PublishSubject<Error> = PublishSubject()
    
    func transform(input: Input) -> Output {
        input.closeTapped
            .subscribe(onNext: { _ in
                self.router.trigger(.dismiss)
            })
            .disposed(by: disposeBag)
        
        let textInputCount = input.textInput
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).count }
        
        let validateError = textInputCount
            .map { (count) -> Error? in
                if count == 0 { return CreatePostError.textInputEmpty }
                if count > 1024 { return CreatePostError.textInputExceed }
                return nil
            }
        
        let requestCreatePost = {
            self.service.create(content: $0)
                .map { post -> Post? in post }
                .catchError { error in
                    self.createPostErrorPublish.onNext(error)
                    return .just(nil)
                }
        }
        
        let contentValidation = input.createTapped
            .withLatestFrom(validateError)
            .map { $0 == nil }
        
        contentValidation
            .filter { $0 }
            .bind(to: isPostingBehavior)
            .disposed(by: disposeBag)
        
        contentValidation
            .filter { $0 }
            .withLatestFrom(input.textInput)
            .flatMap(requestCreatePost)
            .subscribe(onNext: { post in
                self.isPostingBehavior.onNext(false)
                guard post != nil else { return }
                self.router.trigger(.dismiss)
            })
            .disposed(by: disposeBag)
        
        createPostErrorPublish
            .subscribe(onNext: { [weak self]error in
                self?.router.trigger(.alert(error))
            }, onError: { [weak self]error in
                self?.router.trigger(.alert(error))
            })
            .disposed(by: disposeBag)
        
        let validate =  Observable.combineLatest(validateError, contentValidation)
            .map { $0.0 }

        return Output(
            countingText: textInputCount.map { "\($0) / 1024" },
            isPosting: isPostingBehavior.asDriver(onErrorJustReturn: false),
            validate: validate.asDriver(onErrorJustReturn: nil))
    }
}
