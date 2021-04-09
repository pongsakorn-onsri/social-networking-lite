//
//  CreatePostUseCase.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 6/4/2564 BE.
//

import Foundation
import RxSwift
import FirebaseFirestore
import Resolver
import Dto

protocol CreatePostUseCaseType {
    func validate(_ post: Post?) -> ValidationResult
    func createPost(_ dto: CreatePostDto) -> Observable<Post>
}

struct CreatePostUseCase: CreatePostUseCaseType, CreatingPost {
    @Injected var postGateway: PostGatewayType
}
