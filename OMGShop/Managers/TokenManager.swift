//
//  TokenManager.swift
//  OMGShop
//
//  Created by Mederic Petit on 15/11/17.
//  Copyright © 2017-2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

class TokenManager {
    static let shared = TokenManager()

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
            balances.filter({ $0.token.symbol == self.selectedTokenSymbol }).isEmpty {
            self.selectedTokenSymbol = balances.first?.token.symbol
        }
    }

    func selectedBalance(fromBalances balances: [Balance]) -> Balance? {
        return balances.filter({ $0.token.symbol == self.selectedTokenSymbol }).first
    }

    func isSelected(_ token: Token) -> Bool {
        return token.symbol == self.selectedTokenSymbol
    }
}
