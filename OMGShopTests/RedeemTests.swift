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
        let decoder = JSONDecoder()
        //swiftlint:disable:next line_length
        let addressJSON = "{\"object\":\"address\",\"address\":\"2c2e0f2e-fa0f-4abe-8516-9e92cf003486\",\"balances\":[{\"object\":\"balance\",\"amount\":800000,\"minted_token\":{\"symbol\":\"OMG\",\"subunit_to_unit\":100,\"object\":\"minted_token\",\"name\":\"OmiseGO\"}}]}".data(using: .utf8)
        let address = try? decoder.decode(Address.self, from: addressJSON!)
        let product = Product(uid: "1", name: "", description: "", imageURL: "", price: 20000)
        let checkout = Checkout(product: product)
        checkout.address = address
        checkout.selectedBalance = address?.balances.first!
        let viewModel = RedeemPopupViewModel(checkout: checkout)
        XCTAssert(viewModel.initialSliderValue() == 0)
        XCTAssert(viewModel.maximumSliderValue() == Float(20000 / OMGShopManager.shared.setting.tokenValue))
    }

    func testUpdateSliderValues() {
        let decoder = JSONDecoder()
        //swiftlint:disable:next line_length
        let addressJSON = "{\"object\":\"address\",\"address\":\"2c2e0f2e-fa0f-4abe-8516-9e92cf003486\",\"balances\":[{\"object\":\"balance\",\"amount\":800000,\"minted_token\":{\"symbol\":\"OMG\",\"subunit_to_unit\":100,\"object\":\"minted_token\",\"name\":\"OmiseGO\"}}]}".data(using: .utf8)
        let address = try? decoder.decode(Address.self, from: addressJSON!)
        let product = Product(uid: "1", name: "", description: "", imageURL: "", price: 20000)
        let checkout = Checkout(product: product)
        checkout.address = address
        checkout.selectedBalance = address?.balances.first!
        let viewModel = RedeemPopupViewModel(checkout: checkout)
        viewModel.updateRedeem(withSliderValue: 5000)
        XCTAssert(viewModel.initialSliderValue() == 5000)
    }

    func testExistingSliderValues() {
        let decoder = JSONDecoder()
        //swiftlint:disable:next line_length
        let addressJSON = "{\"object\":\"address\",\"address\":\"2c2e0f2e-fa0f-4abe-8516-9e92cf003486\",\"balances\":[{\"object\":\"balance\",\"amount\":800000,\"minted_token\":{\"symbol\":\"OMG\",\"subunit_to_unit\":100,\"object\":\"minted_token\",\"name\":\"OmiseGO\"}}]}".data(using: .utf8)
        let address = try? decoder.decode(Address.self, from: addressJSON!)
        let product = Product(uid: "1", name: "", description: "", imageURL: "", price: 20000)
        let checkout = Checkout(product: product)
        checkout.address = address
        checkout.selectedBalance = address?.balances.first!
        checkout.redeemedToken = 5000
        let viewModel = RedeemPopupViewModel(checkout: checkout)
        XCTAssert(viewModel.initialSliderValue() == 5000)
    }

}
