//
//  RedeemTests.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 27/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import XCTest
@testable import OMGShop
@testable import OmiseGO

class RedeemTests: OMGShopTests {

    func testInitialSliderValues() {
        //swiftlint:disable:next line_length
        let balanceJSON = "{\r\n  \"object\": \"balance\",\r\n  \"minted_token\": {\r\n    \"object\": \"minted_token\",\r\n    \"symbol\": \"OMG\",\r\n    \"name\": \"OmiseGO\",\r\n    \"subunit_to_unit\": 100\r\n  },\r\n  \"address\": \"my_omg_address\",\r\n  \"amount\": 800000\r\n}".data(using: .utf8)
        let balance = try? JSONDecoder().decode(Balance.self, from: balanceJSON!)
        let product = Product(uid: "1", name: "", description: "", imageURL: "", price: 20000)
        let checkout = Checkout(product: product)
        checkout.balance = balance
        let viewModel = RedeemPopupViewModel(checkout: checkout)
        XCTAssert(viewModel.initialSliderValue() == 0)
        XCTAssert(viewModel.maximumSliderValue() == Float(20000 / OMGShopManager.shared.setting.tokenValue))
    }

    func testUpdateSliderValues() {
        //swiftlint:disable:next line_length
        let balanceJSON = "{\r\n  \"object\": \"balance\",\r\n  \"minted_token\": {\r\n    \"object\": \"minted_token\",\r\n    \"symbol\": \"OMG\",\r\n    \"name\": \"OmiseGO\",\r\n    \"subunit_to_unit\": 100\r\n  },\r\n  \"address\": \"my_omg_address\",\r\n  \"amount\": 800000\r\n}".data(using: .utf8)
        let balance = try? JSONDecoder().decode(Balance.self, from: balanceJSON!)
        let product = Product(uid: "1", name: "", description: "", imageURL: "", price: 20000)
        let checkout = Checkout(product: product)
        checkout.balance = balance
        let viewModel = RedeemPopupViewModel(checkout: checkout)
        viewModel.updateRedeem(withSliderValue: 5000)
        XCTAssert(viewModel.initialSliderValue() == 5000)
    }

    func testExistingSliderValues() {
        //swiftlint:disable:next line_length
        let balanceJSON = "{\r\n  \"object\": \"balance\",\r\n  \"minted_token\": {\r\n    \"object\": \"minted_token\",\r\n    \"symbol\": \"OMG\",\r\n    \"name\": \"OmiseGO\",\r\n    \"subunit_to_unit\": 100\r\n  },\r\n  \"address\": \"my_omg_address\",\r\n  \"amount\": 800000\r\n}".data(using: .utf8)
        let balance = try? JSONDecoder().decode(Balance.self, from: balanceJSON!)
        let product = Product(uid: "1", name: "", description: "", imageURL: "", price: 20000)
        let checkout = Checkout(product: product)
        checkout.balance = balance
        checkout.redeemedToken = 5000
        let viewModel = RedeemPopupViewModel(checkout: checkout)
        XCTAssert(viewModel.initialSliderValue() == 5000)
    }

}
