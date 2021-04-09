//
//  FeedNavigator.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 7/4/2564 BE.
//

import Foundation
import XCoordinator
import RxSwift
import RxCocoa

extension Router where RouteType == AppRoute {
    public func triggerToSignIn() -> Driver<User> {
        let delegate = PublishSubject<User>()
        trigger(.authenticate(delegate: delegate))
        return delegate.asDriverOnErrorJustComplete()
    }
    
    public func triggerToCreatePost() -> Driver<Post> {
        let delegate = PublishSubject<Post>()
        trigger(.post(delegate: delegate))
        return delegate.asDriverOnErrorJustComplete()
    }
    
    public func confirmDeletePost(post: Post) -> Driver<Post> {
        let delegate = PublishSubject<Post>()
        trigger(.deleteAlert(post: post, delegate: delegate))
        return delegate.asDriverOnErrorJustComplete()
    }
    
    public func confirmSignOut() -> Driver<Void> {
        let delegate = PublishSubject<Void>()
        trigger(.signout(delegate: delegate))
        return delegate.asDriverOnErrorJustComplete()
    }
}
