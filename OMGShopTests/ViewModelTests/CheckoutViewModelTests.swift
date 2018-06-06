//
//  CheckoutViewModelTests.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 27/10/17.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

import XCTest
@testable import OMGShop
@testable import OmiseGO
import BigInt

class CheckoutViewModelTests: XCTestCase {

    var mockProductAPI: MockProductAPI!
    var mockWalletLoader: MockWalletLoader!
    var sut: CheckoutViewModel!

    override func setUp() {
        super.setUp()
        TokenManager.shared.selectedTokenSymbol = nil
        self.mockProductAPI = MockProductAPI()
        self.mockWalletLoader = MockWalletLoader()
        let product = Product(uid: "1", name: "test", description: "test", imageURL: "", price: 20000)
        self.sut = CheckoutViewModel(product: product,
                                     walletLoader: self.mockWalletLoader,
                                     productAPI: self.mockProductAPI)
    }

    override func tearDown() {
        self.mockProductAPI = nil
        self.mockWalletLoader = nil
        self.sut = nil
        TokenManager.shared.selectedTokenSymbol = nil
        super.tearDown()
    }

    func testLoadWalletCalled() {
        self.sut.loadBalances()
        XCTAssert(self.mockWalletLoader.isLoadWalletCalled)
    }

    func testFailLoadWallet() {
        var didFail = false
        self.sut.onFailGetWallet = {
            XCTAssertEqual($0.message, "unexpected error: Failed to load wallet")
            didFail = true
        }
        self.goToLoadWalletFailed()
        XCTAssert(didFail)
    }

    func testLoadWallet() {
        var successGetWalletCalled = false
        self.sut.onSuccessGetWallet = { successGetWalletCalled = true }
        self.goToLoadWalletFinished()
        let firstBalance = self.mockWalletLoader.wallet!.balances.first!
        XCTAssertEqual(TokenManager.shared.selectedTokenSymbol, firstBalance.token.symbol)
        XCTAssertEqual(self.sut.checkout.wallet, self.mockWalletLoader.wallet!)
        XCTAssertEqual(self.sut.checkout.selectedBalance, firstBalance)
        XCTAssert(successGetWalletCalled)
    }

    func testRedeemButtonStateForSuccess() {
        XCTAssertFalse(self.sut.isRedeemButtonEnabled)
        XCTAssertEqual(self.sut.redeemButtonTitle, "checkout.button.title.redeem.loading".localized())
        self.goToLoadWalletFinished()
        let selectedToken = TokenManager.shared.selectedTokenSymbol!
        XCTAssertTrue(self.sut.isRedeemButtonEnabled)
        XCTAssertEqual(self.sut.redeemButtonTitle,
                       "\("checkout.button.title.redeem.redeem".localized()) \(selectedToken)")
    }

    func testRedeemButtonStateForFailure() {
        XCTAssertFalse(self.sut.isRedeemButtonEnabled)
        XCTAssertEqual(self.sut.redeemButtonTitle, "checkout.button.title.redeem.loading".localized())
        self.goToLoadWalletFailed()
        XCTAssertFalse(self.sut.isRedeemButtonEnabled)
        XCTAssertEqual(self.sut.redeemButtonTitle, "checkout.button.title.redeem.no_balance".localized())
    }

    func testLoadingWhenLoadingWallet() {
        var loadingStatus = false
        self.sut.onLoadStateChange = { loadingStatus = $0 }
        self.sut.loadBalances()
        XCTAssertTrue(loadingStatus)
        self.mockWalletLoader.wallet = StubGenerator.mainWallet()
        self.mockWalletLoader.loadMainWalletSuccess()
        XCTAssertFalse(loadingStatus)
    }

    func testBuyCalled() {
        self.goToLoadWalletFinished()
        self.sut.pay()
        XCTAssert(self.mockProductAPI.isPayCalled)
    }

    func testFailPay() {
        var didFail = false
        self.sut.onFailPay = {
            XCTAssertEqual($0.message, "Error")
            didFail = true
        }
        self.goToLoadWalletFinished()
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
        self.goToLoadWalletFinished()
        self.sut.pay()
        XCTAssertTrue(loadingStatus)
        self.mockProductAPI.pay = StubGenerator.pay()
        self.mockProductAPI.paySuccess()
        XCTAssertFalse(loadingStatus)
    }

    func testPricesCalculation() {
        var discountedPrice: String?
        var totalPrice: String?
        self.goToLoadWalletFinished()
        self.sut.onDiscountPriceChange = { discountedPrice = $0 }
        self.sut.onTotalPriceChange = { totalPrice = $0 }
        let discount: Double = 10000
        self.sut.checkout.discount = BigUInt(discount)
        self.sut.updatePrices()
        XCTAssert(discountedPrice == discount.displayablePrice())
        XCTAssert(self.sut.subTotalPrice == 20000.displayablePrice())
        XCTAssert(totalPrice == (20000 - discount).displayablePrice())
    }

}

extension CheckoutViewModelTests {

    private func goToLoadWalletFinished() {
        self.sut.loadBalances()
        self.mockWalletLoader.wallet = StubGenerator.mainWallet()
        self.mockWalletLoader.loadMainWalletSuccess()
    }

    private func goToLoadWalletFailed() {
        self.sut.loadBalances()
        let error: OMGError = .unexpected(message: "Failed to load wallet")
        self.mockWalletLoader.loadMainWalletFailed(withError: error)
    }

    private func goToPayFinished() {
        self.goToLoadWalletFinished()
        self.sut.pay()
        self.mockProductAPI.pay = StubGenerator.pay()
        self.mockProductAPI.paySuccess()
    }

}
