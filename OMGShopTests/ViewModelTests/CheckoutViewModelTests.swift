//
//  CheckoutViewModelTests.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 27/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import XCTest
@testable import OMGShop
@testable import OmiseGO

class CheckoutViewModelTests: XCTestCase {

    var mockProductAPI: MockProductAPI!
    var mockAddressLoader: MockAddressLoader!
    var sut: CheckoutViewModel!

    override func setUp() {
        super.setUp()
        MintedTokenManager.shared.selectedTokenSymbol = nil
        self.mockProductAPI = MockProductAPI()
        self.mockAddressLoader = MockAddressLoader()
        let product = Product(uid: "1", name: "test", description: "test", imageURL: "", price: 20000)
        self.sut = CheckoutViewModel(product: product,
                                     addressLoader: self.mockAddressLoader,
                                     productAPI: self.mockProductAPI)
    }

    override func tearDown() {
        self.mockProductAPI = nil
        self.mockAddressLoader = nil
        self.sut = nil
        MintedTokenManager.shared.selectedTokenSymbol = nil
        super.tearDown()
    }

    func testLoadAddressCalled() {
        self.sut.loadBalances()
        XCTAssert(self.mockAddressLoader.isLoadAddressCalled)
    }

    func testFailLoadAddress() {
        var didFail = false
        self.sut.onFailGetAddress = {
            XCTAssertEqual($0.message, "unexpected error: Failed to load address")
            didFail = true
        }
        self.goToLoadAddressFailed()
        XCTAssert(didFail)
    }

    func testLoadAddress() {
        var successGetAddressCalled = false
        self.sut.onSuccessGetAddress = { successGetAddressCalled = true }
        self.goToLoadAddressFinished()
        let firstBalance = self.mockAddressLoader.address!.balances.first!
        XCTAssertEqual(MintedTokenManager.shared.selectedTokenSymbol, firstBalance.mintedToken.symbol)
        XCTAssertEqual(self.sut.checkout.address, self.mockAddressLoader.address!)
        XCTAssertEqual(self.sut.checkout.selectedBalance, firstBalance)
        XCTAssert(successGetAddressCalled)
    }

    func testRedeemButtonStateForSuccess() {
        XCTAssertFalse(self.sut.isRedeemButtonEnabled)
        XCTAssertEqual(self.sut.redeemButtonTitle, "checkout.button.title.redeem.loading".localized())
        self.goToLoadAddressFinished()
        let selectedToken = MintedTokenManager.shared.selectedTokenSymbol!
        XCTAssertTrue(self.sut.isRedeemButtonEnabled)
        XCTAssertEqual(self.sut.redeemButtonTitle,
                       "\("checkout.button.title.redeem.redeem".localized()) \(selectedToken)")
    }

    func testRedeemButtonStateForFailure() {
        XCTAssertFalse(self.sut.isRedeemButtonEnabled)
        XCTAssertEqual(self.sut.redeemButtonTitle, "checkout.button.title.redeem.loading".localized())
        self.goToLoadAddressFailed()
        XCTAssertFalse(self.sut.isRedeemButtonEnabled)
        XCTAssertEqual(self.sut.redeemButtonTitle, "checkout.button.title.redeem.no_balance".localized())
    }

    func testLoadingWhenLoadingAddress() {
        var loadingStatus = false
        self.sut.onLoadStateChange = { loadingStatus = $0 }
        self.sut.loadBalances()
        XCTAssertTrue(loadingStatus)
        self.mockAddressLoader.address = StubGenerator().mainAddress()
        self.mockAddressLoader.loadMainAddressSuccess()
        XCTAssertFalse(loadingStatus)
    }

    func testBuyCalled() {
        self.goToLoadAddressFinished()
        self.sut.pay()
        XCTAssert(self.mockProductAPI.isPayCalled)
    }

    func testFailPay() {
        var didFail = false
        self.sut.onFailPay = {
            XCTAssertEqual($0.message, "Error")
            didFail = true
        }
        self.goToLoadAddressFinished()
        self.sut.pay()
        self.mockProductAPI.payFailed(withError: .init(code: .other("Error"), description: "Error"))
        XCTAssert(didFail)
    }

    func testPay() {
        var successMessage: String?
        self.sut.onSuccessPay = { successMessage = $0 }
        self.goToPayFinished()
        XCTAssert(successMessage == "\("checkout.message.pay_success".localized()) \(self.sut.productName)")
    }

    func testLoadingWhenPaying() {
        var loadingStatus = false
        self.sut.onLoadStateChange = { loadingStatus = $0 }
        self.goToLoadAddressFinished()
        self.sut.pay()
        XCTAssertTrue(loadingStatus)
        self.mockProductAPI.pay = StubGenerator().pay()
        self.mockProductAPI.paySuccess()
        XCTAssertFalse(loadingStatus)
    }

    func testPricesCalculation() {
        var discountedPrice: String?
        var totalPrice: String?
        self.goToLoadAddressFinished()
        self.sut.onDiscountPriceChange = { discountedPrice = $0 }
        self.sut.onTotalPriceChange = { totalPrice = $0 }
        let discount: Double = 10000
        self.sut.checkout.discount = discount
        self.sut.updatePrices()
        XCTAssert(discountedPrice == discount.displayablePrice())
        XCTAssert(self.sut.subTotalPrice == 20000.displayablePrice())
        XCTAssert(totalPrice == (20000 - discount).displayablePrice())
    }

}

extension CheckoutViewModelTests {

    private func goToLoadAddressFinished() {
        self.sut.loadBalances()
        self.mockAddressLoader.address = StubGenerator().mainAddress()
        self.mockAddressLoader.loadMainAddressSuccess()
    }

    private func goToLoadAddressFailed() {
        self.sut.loadBalances()
        let error: OmiseGOError = .unexpected(message: "Failed to load address")
        self.mockAddressLoader.loadMainAddressFailed(withError: error)
    }

    private func goToPayFinished() {
        self.goToLoadAddressFinished()
        self.sut.pay()
        self.mockProductAPI.pay = StubGenerator().pay()
        self.mockProductAPI.paySuccess()
    }

}
