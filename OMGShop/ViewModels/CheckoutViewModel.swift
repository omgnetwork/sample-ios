//
//  CheckoutViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 24/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit
import OmiseGO

class CheckoutViewModel: BaseViewModel {

    // Delegate Closures
    var onDiscountPriceChange: ObjectClosure<String>?
    var onTotalPriceChange: ObjectClosure<String>?
    var onFailGetBalances: FailureClosure?
    var onSuccessGetBalances: SuccessClosure?
    var onSuccessPay: ObjectClosure<String>?
    var onFailPay: FailureClosure?

    let viewTitle: String = "checkout.view.title".localized()
    let yourProductLabel: String = "checkout.label.your_product".localized().uppercased()
    let subTotalLabel: String = "checkout.label.sub_total".localized()
    let discountLabel: String = "checkout.label.discount".localized()
    let totalLabel: String = "checkout.label.total".localized()
    let summaryLabel: String = "checkout.label.summary".localized().uppercased()
    let redeemButtonTitle: String = "checkout.button.title.redeem".localized()
    let payButtonTitle: String = "checkout.button.title.pay".localized()

    let productName: String
    let productPrice: String
    let productImageURL: URL?

    let subTotalPrice: String
    var discountPrice: String = 0.0.displayablePrice() {
        didSet { self.onDiscountPriceChange?(discountPrice) }
    }
    var totalPrice: String = 0.0.displayablePrice() {
        didSet { self.onTotalPriceChange?(totalPrice) }
    }

    let checkout: Checkout!

    init(product: Product) {
        self.checkout = Checkout(product: product)
        self.productName = product.name
        self.productImageURL = URL(string: product.imageURL)
        self.productPrice = product.displayPrice
        self.subTotalPrice = product.displayPrice
        super.init()
        self.updatePrices()
    }

    func loadBalances() {
        let decoder = JSONDecoder()
        //swiftlint:disable:next line_length
        let balanceJSON = "{\r\n  \"object\": \"balance\",\r\n  \"minted_token\": {\r\n    \"object\": \"minted_token\",\r\n    \"symbol\": \"OMG\",\r\n    \"name\": \"OmiseGO\",\r\n    \"subunit_to_unit\": 100\r\n  },\r\n  \"address\": \"my_omg_address\",\r\n  \"amount\": 800000\r\n}".data(using: .utf8)
        let balance = try? decoder.decode(Balance.self, from: balanceJSON!)
        self.checkout.balance = balance
        self.onSuccessGetBalances?()
        // TODO: For later
//        Balance.getAll { (result) in
//            switch result {
//            case .success(data: let balances):
//                self.checkout.balance = balances.first
//                self.onSuccessGetBalances?()
//            case .fail(error: let error):
//                self.onFailGetBalances?(.omiseGOError(error: error))
//            }
//        }
    }

    func updatePrices() {
        self.totalPrice = self.checkout.total.displayablePrice()
        self.discountPrice = self.checkout.discount.displayablePrice()
    }

    func pay() {
        self.onSuccessPay?("\("checkout.message.pay_success".localized()) \(self.productName)")
    }

}
