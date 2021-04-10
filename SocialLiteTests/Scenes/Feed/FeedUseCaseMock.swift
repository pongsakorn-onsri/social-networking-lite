//
//  FeedUseCaseMock.swift
//  SocialLiteTests
//
//  Created by Pongsakorn Onsri on 10/4/2564 BE.
//

import RxSwift
import Dto
import FirebaseAuth

@testable import SocialLite
final class FeedUseCaseMock: FeedUseCaseType {
    typealias User = SocialLite.User
    
    var getUserCalled: Bool = false
    func getUser() -> Observable<User> {
        getUserCalled = true
        return .just(User(uid: "userTest", providerID: "test"))
    }
    
    var getPostListCalled: Bool = false
    func getPostList(dto: GetPostListDto) -> Observable<[Post]> {
        getPostListCalled = true
        let post = Post(userId: "", displayName: "", content: "", timestamp: Date())
        let posts: [Post] = Array(repeating: post, count: 10)
            .enumerated()
            .map { index, post in
                var post = post
                post.documentId = "\(index + 1)"
                if let documentId = dto.document?.documentID, let startId = Int(documentId) {
                    switch dto.type {
                    case .new:
                        post.documentId = "\(startId - (index + 1))"
                    case .old:
                        post.documentId = "\(startId + index + 1)"
                    }
                }
                return post
            }
        switch dto.type {
        case .new:
            return Observable.just(Array(posts[0...4]))
        case .old:
            return Observable.just(Array(posts.reversed()[0...2]))
        }
    }
    
    var removePostCalled: Bool = false
    func removePost(_ post: DeletePostDto) -> Observable<Void> {
        removePostCalled = true
        return .just(())
    }
    
    var signOutCalled: Bool = false
    func signOut() -> Observable<Void> {
        signOutCalled = true
        return .just(())
    }
}
