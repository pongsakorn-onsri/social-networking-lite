//
//  CreatePostUseCaseTests.swift
//  SocialLiteTests
//
//  Created by Pongsakorn Onsri on 10/4/2564 BE.
//

import RxSwift
import Dto

@testable import SocialLite
final class CreatePostUseCaseMock: CreatePostUseCaseType {
    
    var validatePostCalled: Bool = false
    func validate(_ post: Post?) -> ValidationResult {
        validatePostCalled = true
        return CreatePostDto.validateContent(post).mapToVoid()
    }
    
    var createPostCalled: Bool = false
    func createPost(_ dto: CreatePostDto) -> Observable<Post> {
        createPostCalled = true
        if let post = dto.post {
            return .just(post)
        } else {
            return .error(NSError(domain: String(describing: self), code: 400, userInfo: nil))
        }
    }
    
}
