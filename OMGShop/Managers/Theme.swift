//
//  Theme.swift
//  OMGShop
//
//  Created by Mederic Petit on 20/10/17.
//  Copyright © 2017-2018 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

struct Theme {
    static func apply() {
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.barTintColor = .white
        navigationBarAppearance.tintColor = Color.omiseGOBlue.uiColor()
        navigationBarAppearance.isTranslucent = false
        navigationBarAppearance.titleTextAttributes = [
            .font: Font.avenirMedium.withSize(20),
            .foregroundColor: Color.omiseGOBlue.uiColor()
        ]
        let barButtonAppearance = UIBarButtonItem.appearance()
        barButtonAppearance.setTitleTextAttributes([
            .font: Font.avenirMedium.withSize(17),
            .foregroundColor: Color.omiseGOBlue.uiColor()
        ], for: .normal)
        barButtonAppearance.setTitleTextAttributes([
            .font: Font.avenirMedium.withSize(17),
            .foregroundColor: Color.omiseGOBlue.uiColor()
        ], for: .highlighted)
    }
}

enum Color: String {
    case omiseGOBlue = "1A53F0"
    case transactionDebitRed = "e74c3c"
    case transactionCreditGreen = "2ecc71"

    func uiColor(withAlpha alpha: CGFloat? = 1.0) -> UIColor {
        return UIColor.color(fromHexString: self.rawValue, alpha: alpha)
    }

    func cgColor() -> CGColor {
        return self.uiColor().cgColor
    }
}

enum Font: String {
    case avenirMedium = "Avenir-Medium"
    case avenirBook = "Avenir-Book"

    func withSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: self.rawValue, size: size)!
    }
}
