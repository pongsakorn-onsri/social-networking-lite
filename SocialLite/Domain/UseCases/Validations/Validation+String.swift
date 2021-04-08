//
//  Validation+String.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 8/4/2564 BE.
//

import ValidatedPropertyKit

extension Validation where Value == String {
    public static func matches(_ pattern: String,
                               options: NSRegularExpression.Options = .init(),
                               matchingOptions: NSRegularExpression.MatchingOptions = .init(),
                               message: String) -> Validation {
        guard let regularExpression = try? NSRegularExpression(pattern: pattern, options: options) else {
            return .init { _ in .failure("Invalid regular expression: \(pattern)") }
        }
        
        return self.matches(
            regularExpression,
            matchingOptions: matchingOptions,
            message: message
        )
    }
    
    public static func matches(_ regex: NSRegularExpression,
                               matchingOptions: NSRegularExpression.MatchingOptions = .init(),
                               message: String) -> Validation {
        return .init { value in
            let firstMatchIsAvailable = regex.firstMatch(
                in: value,
                options: matchingOptions,
                range: .init(value.startIndex..., in: value)
                ) != nil
            
            if firstMatchIsAvailable {
                return .success(())
            } else {
                return .failure(ValidationError(message: message))
            }
        }
    }
    
    public static func isNumber(_ message: String) -> Validation {
        return self.matches(#"[+-]?\d+(\.\d+)?([Ee][+-]?\d+)?"#, message: message)
    }
    
    public static func isEmail(_ message: String) -> Validation {
        return self.matches("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}", message: message)
    }
}
