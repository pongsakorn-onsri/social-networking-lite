//
//  FeedUseCase.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 6/4/2564 BE.
//

import Foundation
import RxSwift
import FirebaseFirestore
import Resolver

protocol FeedUseCaseType {
    func getUser() -> Observable<User>
    func getPostList(dto: GetPostListDto) -> Observable<[Post]>
    func removePost(_ post: DeletePostDto) -> Observable<Void>
    func signOut() -> Observable<Void>
}

struct FeedUseCase: FeedUseCaseType, GettingPostList, SigningOut, DeletingPost {
    
    @Injected var authenGateway: AuthenGatewayType
    @Injected var postGateway: PostGatewayType
    
    func getUser() -> Observable<User> {
        authenGateway.getUser()
    }
}
