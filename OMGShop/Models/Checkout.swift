//
//  Checkout.swift
//  OMGShop
//
//  Created by Mederic Petit on 25/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import OmiseGO

class Checkout {

    var balance: Balance?
    var total: Double = 0
    var redeemedToken: Double = 0 {
        didSet { self.discount = redeemedToken * OMGShopManager.shared.setting.tokenValue }
    }
    var discount: Double = 0 {
        didSet { self.updateTotalPrice() }
    }

    let subTotal: Double
    let product: Product

    init(product: Product) {
        self.product = product
        self.subTotal = product.price
        self.updateTotalPrice()
    }

    private func updateTotalPrice() {
        self.total = self.subTotal - self.discount
    }

}
