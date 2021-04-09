//
//  Result+Extensions.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 9/4/2564 BE.
//

import Foundation
import ValidatedPropertyKit

extension Result where Failure == ValidationError {
    
    public var firstMessage: String {
        switch self {
        case .success:
            return ""
        case .failure(let error):
            return error.description.components(separatedBy: "\n").first ?? ""
        }
    }
}
