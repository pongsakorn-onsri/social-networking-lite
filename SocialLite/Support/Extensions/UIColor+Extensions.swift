//
//  UIColor+Extensions.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 3/4/2564 BE.
//

import Foundation
import UIKit

extension UIColor {
    /// SwifterSwift: Create Color from RGB values with optional transparency.
        ///
        /// - Parameters:
        ///   - red: red component.
        ///   - green: green component.
        ///   - blue: blue component.
        ///   - transparency: optional transparency value (default is 1).
        convenience init?(red: Int, green: Int, blue: Int, transparency: CGFloat = 1) {
            guard red >= 0, red <= 255 else { return nil }
            guard green >= 0, green <= 255 else { return nil }
            guard blue >= 0, blue <= 255 else { return nil }

            var trans = transparency
            if trans < 0 { trans = 0 }
            if trans > 1 { trans = 1 }

            self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: trans)
        }
    
    /// SwifterSwift: Create Color from hexadecimal value with optional transparency.
        ///
        /// - Parameters:
        ///   - hex: hex Int (example: 0xDECEB5).
        ///   - transparency: optional transparency value (default is 1).
        convenience init?(hex: Int, transparency: CGFloat = 1) {
            var trans = transparency
            if trans < 0 { trans = 0 }
            if trans > 1 { trans = 1 }

            let red = (hex >> 16) & 0xFF
            let green = (hex >> 8) & 0xFF
            let blue = hex & 0xFF
            self.init(red: red, green: green, blue: blue, transparency: trans)
        }
}
