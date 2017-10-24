//
//  ProductListViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 24/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit

class ProductListViewModel: BaseViewModel {

    // Delegate closures
    var reloadTableViewClosure: EmptyClosure?

    var viewTitle: String = "product_list.view.title".localized()

    private var productCellViewModels: [ProductCellViewModel]! = [] {
        didSet {
            self.reloadTableViewClosure?()
        }
    }

    func getProducts() {
        // TODO: Get products from API
        let products = Product.dummies()
        self.process(products)
    }

    private func process(_ products: [Product]) {
        var newCellViewModels: [ProductCellViewModel] = []
        products.forEach({ newCellViewModels.append(ProductCellViewModel(product: $0)) })
        self.productCellViewModels.append(contentsOf: newCellViewModels)
    }

}

extension ProductListViewModel {

    func productCellViewModel(at indexPath: IndexPath) -> ProductCellViewModel {
        return self.productCellViewModels[indexPath.row]
    }

    func numberOfCell() -> Int {
        return self.productCellViewModels.count
    }

}
