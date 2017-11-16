//
//  TokenCellViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 14/11/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit
import OmiseGO

class TokenCellViewModel: BaseViewModel {

    var tokenSymbol: String = "-"
    var tokenAmount: String = "0"
    var isSelected: Bool = false

    private var balance: Balance!

    init(balance: Balance, isSelected: Bool) {
        self.tokenSymbol = balance.mintedToken.symbol
        self.tokenAmount = balance.displayAmount(withPrecision: 2)
        self.isSelected = isSelected
    }

}
