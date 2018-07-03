//
//  ProductCellViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 24/10/17.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

import UIKit

class ProductCellViewModel: BaseViewModel {
    let name: String
    let desc: String
    let displayPrice: String
    let imageURL: URL?

    let product: Product!

    init(product: Product) {
        self.product = product
        self.name = product.name
        self.desc = product.description
        self.displayPrice = product.price.displayablePrice()
        self.imageURL = URL(string: product.imageURL)
    }
}
