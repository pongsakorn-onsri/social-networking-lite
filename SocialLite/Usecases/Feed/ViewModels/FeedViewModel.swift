//
//  FeedViewModel.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 2/4/2564 BE.
//

import Foundation
import XCoordinator
import RxSwift
import RxCocoa

class FeedViewModel: BaseViewModel {
    
    struct Input {
        let createPostTapped: Observable<Void>
        let signOutTapped: Observable<Void>
        let userChanged: Observable<User?>
    }
    
    struct Output {
        let user: Driver<User?>
    }
    
    var refreshAction: PublishSubject<Void> = PublishSubject()
    
    func transform(input: Input) -> Output {
        input.userChanged
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self]user in
                if user == nil {
                    self?.router.trigger(.authenticate)
                }
            })
            .disposed(by: disposeBag)
        
        input.createPostTapped
            .subscribe(onNext: { [weak self]_ in
                self?.router.trigger(.post)
            })
            .disposed(by: disposeBag)
        
        input.signOutTapped
            .subscribe(onNext: {
                self.router.trigger(.signout)
            })
            .disposed(by: disposeBag)
        
        return Output(
            user: input.userChanged
                .compactMap { $0 }
                .asDriver(onErrorJustReturn: nil)
        )
    }
}
