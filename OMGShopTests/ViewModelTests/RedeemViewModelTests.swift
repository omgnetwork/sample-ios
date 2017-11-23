//
//  RedeemViewModelTests.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 27/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import XCTest
@testable import OMGShop
@testable import OmiseGO

class RedeemViewModelTests: XCTestCase {

    var checkout: Checkout!
    var address: Address!
    var product: Product!
    var sut: RedeemPopupViewModel!

    override func setUp() {
        super.setUp()
        self.address = StubGenerator().mainAddress()
        self.product = StubGenerator().stubProducts().first!
        self.checkout = Checkout(product: product)
        self.checkout.address = address
        self.checkout.selectedBalance = address?.balances.first!
    }

    override func tearDown() {
        super.tearDown()
        self.address = nil
        self.address = nil
        self.product = nil
        self.sut = nil
    }

    func testInitialSliderValues() {
        self.sut = RedeemPopupViewModel(checkout: self.checkout)
        XCTAssert(self.sut.initialSliderValue() == 0)
        XCTAssert(self.sut.maximumSliderValue() == Float(20000 / OMGShopManager.shared.setting.tokenValue))
    }

    func testUpdateSliderValues() {
        self.sut = RedeemPopupViewModel(checkout: self.checkout)
        self.sut.updateRedeem(withSliderValue: 5000)
        XCTAssert(self.sut.initialSliderValue() == 5000)
    }

    func testExistingSliderValues() {
        self.checkout.redeemedToken = 5000
        self.sut = RedeemPopupViewModel(checkout: checkout)
        XCTAssert(self.sut.initialSliderValue() == 5000)
    }

}
