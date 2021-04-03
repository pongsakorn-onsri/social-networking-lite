//
//  Theme.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 3/4/2564 BE.
//

import Foundation
import MaterialComponents.MaterialContainerScheme

func globalContainerScheme() -> MDCContainerScheming {
    let containerScheme = MDCContainerScheme()
    containerScheme.colorScheme.primaryColor = .orange
    
    let fontName = "MarkerFelt-Thin"
    if let headline6 = UIFont(name: fontName, size: 20) {
        containerScheme.typographyScheme.headline6 = headline6
    }
    
    if let button = UIFont(name: fontName, size: 14) {
        containerScheme.typographyScheme.button = button
    }
    return containerScheme
}

let containerScheme = globalContainerScheme()
