//
//  CreatePost.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 8/4/2564 BE.
//

import Foundation

struct CreatePostDto {
    var post: Post
    
    init(post: Post) {
        self.post = post
    }
}

protocol CreatingPost {
    var postGateway: PostGatewayType { get }
}
