//
//  UIFont+Extensions.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 3/4/2564 BE.
//

import Foundation
import UIKit

public extension UIFont {
    func withWeight(_ weight: UIFont.Weight, size: CGFloat) -> UIFont {
        var attributes = fontDescriptor.fontAttributes
        var traits = attributes[.traits] as? [UIFontDescriptor.TraitKey: Any] ?? [:]
        traits[.weight] = weight
        
        attributes[.name] = nil
        attributes[.traits] = traits
        attributes[.family] = familyName
        
        let descriptor = UIFontDescriptor(fontAttributes: attributes)
        
        return UIFont(descriptor: descriptor, size: size)
    }
}
