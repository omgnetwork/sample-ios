//
//  TokenCellViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 14/11/17.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

import OmiseGO

class TokenCellViewModel: BaseViewModel {
    var tokenSymbol: String = "-"
    var tokenAmount: String = "0"
    var isSelected: Bool = false

    private var balance: Balance!

    init(balance: Balance, isSelected: Bool) {
        self.tokenSymbol = balance.token.symbol
        self.tokenAmount = balance.displayAmount(withPrecision: 3)
        self.isSelected = isSelected
    }
}
