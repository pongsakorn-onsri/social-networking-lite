//
//  Validation+Collection.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 8/4/2564 BE.
//

import ValidatedPropertyKit

extension Validation where Value: Collection {
    
    public static func nonEmpty(_ message: String) -> Validation {
        return .init { value in
            if !value.isEmpty {
                return .success(())
            } else {
                return .failure(ValidationError(message: message))
            }
        }
    }
    
    public static func minLength(min: Int, message: String) -> Validation {
        return .init { value in
            if value.count >= min {
                return .success(())
            } else {
                return .failure(ValidationError(message: message))
            }
        }
    }
    
    public static func maxLength(max: Int, message: String) -> Validation {
        return .init { value in
            if value.count <= max {
                return .success(())
            } else {
                return .failure(ValidationError(message: message))
            }
        }
    }
}
