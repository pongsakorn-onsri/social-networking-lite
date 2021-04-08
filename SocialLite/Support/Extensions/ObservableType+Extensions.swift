//
//  ObservableType+Extensions.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 7/4/2564 BE.
//

import RxSwift
import RxCocoa

extension ObservableType {
    
    public func asDriverOnErrorJustComplete() -> Driver<Element> {
        return asDriver { _ in
            return Driver.empty()
        }
    }
}
