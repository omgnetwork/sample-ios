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
    var onFailLoadProducts: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?

    let viewTitle: String = "product_list.view.title".localized()

    private var productCellViewModels: [ProductCellViewModel]! = [] {
        didSet {
            self.reloadTableViewClosure?()
        }
    }

    var isLoading: Bool = false {
        didSet { self.onLoadStateChange?(self.isLoading) }
    }

    func getProducts() {
        self.isLoading = true
        ProductAPI.getAll { (response) in
            switch response {
            case .success(data: let products):
                self.process(products)
                self.isLoading = false
            case .fail(error: let error):
                self.isLoading = false
                self.onFailLoadProducts?(error)
            }
        }
    }

    private func process(_ products: [Product]) {
        var newCellViewModels: [ProductCellViewModel] = []
        products.forEach({ newCellViewModels.append(ProductCellViewModel(product: $0)) })
        self.productCellViewModels = newCellViewModels
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
