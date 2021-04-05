//
//  CreatePostViewModel.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 3/4/2564 BE.
//

import UIKit
import RxSwift

final class CreatePostViewModel: BaseViewModel {

    struct Input {
        let closeTapped: Observable<Void>
        let createTapped: Observable<Void>
    }
    
    struct Output {
        
    }
    
    func transform(input: Input) -> Output {
        input.closeTapped
            .subscribe(onNext: { _ in
                self.router.trigger(.dismiss)
            })
            .disposed(by: disposeBag)
        
        return Output()
    }
}
