//
//  ThemeTests.swift
//  SocialLiteTests
//
//  Created by Pongsakorn Onsri on 10/4/2564 BE.
//

import XCTest
import Quick
import Nimble
import MaterialComponents.MaterialContainerScheme

@testable import SocialLite
class ThemeTests: QuickSpec {

    override func spec() {
        describe("As global theme") {
            var theme: MDCContainerScheming!
            
            it("has global") {
                theme = containerScheme
                
                expect(theme).toNot(beNil())
                expect(theme.colorScheme.primaryColor) == UIColor(hex: 0x37966F)
                expect(theme.colorScheme.primaryColorVariant) == UIColor(hex: 0x356859)
                expect(theme.colorScheme.onPrimaryColor) == UIColor(hex: 0xB9E4C9)
                expect(theme.colorScheme.secondaryColor) == UIColor(hex: 0xFD5523)
                expect(theme.colorScheme.onSecondaryColor) == UIColor(hex: 0xFFFBE6)
            }
            
            it("initialize") {
                theme = globalContainerScheme()
                
                expect(theme).toNot(beNil())
                expect(theme.colorScheme.primaryColor) == UIColor(hex: 0x37966F)
                expect(theme.colorScheme.primaryColorVariant) == UIColor(hex: 0x356859)
                expect(theme.colorScheme.onPrimaryColor) == UIColor(hex: 0xB9E4C9)
                expect(theme.colorScheme.secondaryColor) == UIColor(hex: 0xFD5523)
                expect(theme.colorScheme.onSecondaryColor) == UIColor(hex: 0xFFFBE6)
                
                let fontLekton = UIFont(name: "Lekton", size: 20)!
                let fontMontserrat = UIFont(name: "Montserrat", size: 20)!
                
                expect(theme.typographyScheme.headline1) == fontMontserrat.withWeight(.semibold, size: 96)
                expect(theme.typographyScheme.headline2) == fontMontserrat.withWeight(.semibold, size: 60)
                expect(theme.typographyScheme.headline3) == fontMontserrat.withWeight(.semibold, size: 48)
                expect(theme.typographyScheme.headline4) == fontMontserrat.withWeight(.semibold, size: 34)
                expect(theme.typographyScheme.headline5) == fontMontserrat.withWeight(.semibold, size: 24)
                expect(theme.typographyScheme.headline6) == fontLekton.withWeight(.semibold, size: 21)
                expect(theme.typographyScheme.subtitle1) == fontLekton.withWeight(.bold, size: 17)
                expect(theme.typographyScheme.subtitle2) == fontLekton.withWeight(.bold, size: 15)
                expect(theme.typographyScheme.body1) == fontMontserrat.withWeight(.semibold, size: 16)
                expect(theme.typographyScheme.body2) == fontMontserrat.withWeight(.regular, size: 14)
                expect(theme.typographyScheme.button) == fontMontserrat.withWeight(.bold, size: 14)
                expect(theme.typographyScheme.caption) == fontMontserrat.withWeight(.medium, size: 12)
                expect(theme.typographyScheme.overline) == fontMontserrat.withWeight(.regular, size: 10)
            }
        }
    }

}
