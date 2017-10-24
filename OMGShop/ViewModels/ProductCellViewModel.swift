//
//  ProductCellViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 24/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
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
        self.displayPrice = product.displayPrice
        self.imageURL = URL(string: product.imageURL)
    }

}
