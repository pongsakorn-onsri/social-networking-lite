//
//  PostGatewayMock.swift
//  SocialLiteTests
//
//  Created by Pongsakorn Onsri on 10/4/2564 BE.
//

import Foundation
import RxSwift

@testable import SocialLite
class PostGatewayMock: PostGatewayType {
    
    var getPostListCalled: Bool = false
    func getPostList(dto: GetPostListDto) -> Observable<[Post]> {
        getPostListCalled = true
        let post = Post(userId: "", displayName: "", content: "", timestamp: Date())
        switch dto.type {
        case .new:
            return Observable.just([post, post, post, post, post])
        case .old:
            return Observable.just([post, post, post])
        }
    }
    
    var createPostCalled: Bool = false
    func createPost(dto: CreatePostDto) -> Observable<Post> {
        createPostCalled = true
        if let post = dto.post {
            return .just(post)
        } else {
            return .error(NSError(domain: "post", code: 400, userInfo: [:]))
        }
    }
    
    var removePostCalled: Bool = false
    func removePost(_ dto: DeletePostDto) -> Observable<Void> {
        removePostCalled = true
        return Observable.just(())
    }
    
}
