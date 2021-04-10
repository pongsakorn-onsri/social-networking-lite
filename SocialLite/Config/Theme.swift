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
    containerScheme.colorScheme.primaryColor = UIColor(hex: 0x37966F)!
    containerScheme.colorScheme.primaryColorVariant = UIColor(hex: 0x356859)!
    containerScheme.colorScheme.onPrimaryColor = UIColor(hex: 0xB9E4C9)!
    containerScheme.colorScheme.secondaryColor = UIColor(hex: 0xFD5523)!
    containerScheme.colorScheme.onSecondaryColor = UIColor(hex: 0xFFFBE6)!
    
    let fontLekton = UIFont(name: "Lekton", size: 20)!
    let fontMontserrat = UIFont(name: "Montserrat", size: 20)!
    
    containerScheme.typographyScheme.headline1 = fontMontserrat.withWeight(.semibold, size: 96)
    containerScheme.typographyScheme.headline2 = fontMontserrat.withWeight(.semibold, size: 60)
    containerScheme.typographyScheme.headline3 = fontMontserrat.withWeight(.semibold, size: 48)
    containerScheme.typographyScheme.headline4 = fontMontserrat.withWeight(.semibold, size: 34)
    containerScheme.typographyScheme.headline5 = fontMontserrat.withWeight(.semibold, size: 24)
    containerScheme.typographyScheme.headline6 = fontLekton.withWeight(.semibold, size: 21)
    containerScheme.typographyScheme.subtitle1 = fontLekton.withWeight(.bold, size: 17)
    containerScheme.typographyScheme.subtitle2 = fontLekton.withWeight(.bold, size: 15)
    containerScheme.typographyScheme.body1 = fontMontserrat.withWeight(.semibold, size: 16)
    containerScheme.typographyScheme.body2 = fontMontserrat.withWeight(.regular, size: 14)
    containerScheme.typographyScheme.button = fontMontserrat.withWeight(.bold, size: 14)
    containerScheme.typographyScheme.caption = fontMontserrat.withWeight(.medium, size: 12)
    containerScheme.typographyScheme.overline = fontMontserrat.withWeight(.regular, size: 10)
    return containerScheme
}

let containerScheme = globalContainerScheme()

