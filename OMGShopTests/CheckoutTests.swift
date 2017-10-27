//
//  CheckoutTests.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 27/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import XCTest
@testable import OMGShop

class CheckoutTests: OMGShopTests {

    func testGetBalance() {
        let expectation = self.expectation(description: "get balance")
        let product = Product(name: "test", description: "test", imageURL: "", price: 20000)
        let viewModel = CheckoutViewModel(product: product)
        viewModel.onSuccessGetBalances = {
            expectation.fulfill()
        }
        viewModel.onFailGetBalances = {
            XCTFail($0.message)
        }
        viewModel.loadBalances()
        waitForExpectations(timeout: 15.0, handler: nil)
    }

    func testPricesCalculation() {
        let productPrice: Double = 20000
        let product = Product(name: "test", description: "test", imageURL: "", price: productPrice)
        let viewModel = CheckoutViewModel(product: product)
        var discountedPrice: String?
        var totalPrice: String?
        viewModel.onDiscountPriceChange = {
            discountedPrice = $0
        }
        viewModel.onTotalPriceChange = {
            totalPrice = $0
        }
        let discount: Double = 10000
        viewModel.checkout.discount = discount
        viewModel.updatePrices()
        XCTAssert(discountedPrice == discount.displayablePrice())
        XCTAssert(viewModel.subTotalPrice == productPrice.displayablePrice())
        XCTAssert(totalPrice == (productPrice - discount).displayablePrice())
    }

    func testPay() {
        let expectation = self.expectation(description: "pay")
        let product = Product(name: "test", description: "test", imageURL: "", price: 20000)
        let viewModel = CheckoutViewModel(product: product)
        viewModel.onSuccessPay = { _ in
            expectation.fulfill()
        }
        viewModel.onFailPay = {
            XCTFail($0.message)
        }
        viewModel.pay()
        waitForExpectations(timeout: 15.0, handler: nil)
    }

}
