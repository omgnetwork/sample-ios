//
//  Checkout.swift
//  OMGShop
//
//  Created by Mederic Petit on 25/10/17.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

import OmiseGO
import BigInt

class Checkout {

    var selectedBalance: Balance!
    var wallet: Wallet?
    var total: BigInt = 0
    var redeemedToken: BigInt = 0 {
        didSet { self.discount = redeemedToken }
    }
    var discount: BigInt = 0 {
        didSet { self.updateTotalPrice() }
    }

    let subTotal: BigInt
    let product: Product

    init(product: Product) {
        self.product = product
        self.subTotal = BigInt(product.price)
        self.updateTotalPrice()
    }

    private func updateTotalPrice() {
        self.total = self.subTotal - self.discount
    }

}
