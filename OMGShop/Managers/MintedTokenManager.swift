//
//  MintedTokenManager.swift
//  OMGShop
//
//  Created by Mederic Petit on 15/11/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit
import OmiseGO

class MintedTokenManager {

    static let shared = MintedTokenManager()

    var selectedTokenSymbol: String? {
        get {
            return UserDefaults.standard.string(forKey: UserDefaultKeys.selectedTokenSymbol.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultKeys.selectedTokenSymbol.rawValue)
        }
    }

    func setDefaultTokenSymbolIfNotPresent(withBalances balances: [Balance]) {
        if self.selectedTokenSymbol == nil ||
            balances.filter({$0.mintedToken.symbol == self.selectedTokenSymbol}).isEmpty {
            self.selectedTokenSymbol = balances.first?.mintedToken.symbol
        }
    }

    func selectedBalance(fromBalances balances: [Balance]) -> Balance? {
        return balances.filter({$0.mintedToken.symbol == self.selectedTokenSymbol}).first
    }

    func isSelected(_ mintedToken: MintedToken) -> Bool {
        return mintedToken.symbol == self.selectedTokenSymbol
    }

}
