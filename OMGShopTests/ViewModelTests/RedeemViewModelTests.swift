//
//  RedeemViewModelTests.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 27/10/17.
//  Copyright © 2017-2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import OMGShop
@testable import OmiseGO
import XCTest

class RedeemViewModelTests: XCTestCase {
    var checkout: Checkout!
    var wallet: Wallet!
    var product: Product!
    var sut: RedeemPopupViewModel!

    override func setUp() {
        super.setUp()
        self.wallet = StubGenerator.mainWallet()
        self.product = StubGenerator.stubProducts().first!
        self.checkout = Checkout(product: self.product)
        self.checkout.wallet = wallet
        self.checkout.selectedBalance = self.wallet?.balances.first!
    }

    override func tearDown() {
        super.tearDown()
        self.wallet = nil
        self.product = nil
        self.sut = nil
    }

    func testInitialSliderValues() {
        self.sut = RedeemPopupViewModel(checkout: self.checkout)
        XCTAssert(self.sut.initialSliderValue() == 0)
        XCTAssert(self.sut.maximumSliderValue() == Float(20000))
    }

    func testUpdateSliderValues() {
        self.sut = RedeemPopupViewModel(checkout: self.checkout)
        self.sut.updateRedeem(withSliderValue: 5000)
        XCTAssert(self.sut.initialSliderValue() == 5000)
    }

    func testExistingSliderValues() {
        self.checkout.redeemedToken = 5000
        self.sut = RedeemPopupViewModel(checkout: self.checkout)
        XCTAssert(self.sut.initialSliderValue() == 5000)
    }
}
