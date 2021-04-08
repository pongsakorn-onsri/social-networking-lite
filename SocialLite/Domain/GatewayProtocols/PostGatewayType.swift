//
//  PostGatewayType.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 8/4/2564 BE.
//

import Foundation
import RxSwift

protocol PostGatewayType {
    func getPostList(dto: GetPostListDto) -> Observable<[Post]>
    func createPost(dto: CreatePostDto) -> Observable<Post>
    func removePost(_ post: DeletePostDto) -> Observable<Void>
}
