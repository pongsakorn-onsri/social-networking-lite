//
//  CreatePost.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 8/4/2564 BE.
//

import Foundation
import Dto
import ValidatedPropertyKit

struct CreatePostDto: Dto {
    
    @Validated(
        .keyPath(\.content,
                 .notContains("fucking", options: .caseInsensitive, "Found rude words. Please change your text.") &&
                    .nonEmpty("Please input your content.") &&
                    .maxLength(max: 1024, message: "Text input exceed limit 1024 charactors.")
        )
    )
    var post: Post?
    
    var validatedProperties: [ValidatedProperty] {
        return [_post]
    }
}

extension CreatePostDto {
    init(post: Post) {
        self.post = post
    }
    
    static func validateContent(_ content: Post?) -> Result<Post, ValidationError> {
        CreatePostDto()._post.isValid(value: content)
    }
}

protocol CreatingPost {
    var postGateway: PostGatewayType { get }
}

extension CreatingPost {
    func validate(_ post: Post?) -> ValidationResult {
        CreatePostDto.validateContent(post).mapToVoid()
    }
}
