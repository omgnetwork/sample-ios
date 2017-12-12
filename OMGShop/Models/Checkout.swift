//
//  Checkout.swift
//  OMGShop
//
//  Created by Mederic Petit on 25/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import OmiseGO
import BigInt

class Checkout {

    var selectedBalance: Balance!
    var address: Address?
    var total: BigUInt = 0
    var redeemedToken: BigUInt = 0 {
        didSet { self.discount = redeemedToken }
    }
    var discount: BigUInt = 0 {
        didSet { self.updateTotalPrice() }
    }

    let subTotal: BigUInt
    let product: Product

    init(product: Product) {
        self.product = product
        self.subTotal = BigUInt(product.price)
        self.updateTotalPrice()
    }

    private func updateTotalPrice() {
        self.total = self.subTotal - self.discount
    }

}
