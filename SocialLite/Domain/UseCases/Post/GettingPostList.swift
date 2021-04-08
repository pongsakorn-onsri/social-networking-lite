//
//  GettingPostList.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 8/4/2564 BE.
//

import Foundation
import RxSwift
import FirebaseFirestore

struct GetPostListDto {
    enum GetType {
        case new
        case old
    }
    var type: GetType = .new
    var document: DocumentSnapshot?
}


protocol GettingPostList {
    var postGateway: PostGatewayType { get }
}

extension GettingPostList {
    func getPostList(dto: GetPostListDto) -> Observable<[Post]> {
        return postGateway.getPostList(dto: dto)
    }
}
