//
//  TRequestConsumerViewModelTests.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 10/4/18.
//  Copyright © 2017-2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import OMGShop
import OmiseGO
import XCTest

class TRequestConsumerViewModelTests: XCTestCase {
    var mockTransactionConsumer: MockTransactionConsumer!
    var mockWalletLoader: MockWalletLoader!
    var sut: TRequestConsumerViewModel!

    override func setUp() {
        super.setUp()
        self.mockTransactionConsumer = MockTransactionConsumer()
        self.mockWalletLoader = MockWalletLoader()
        self.sut = TRequestConsumerViewModel(transactionRequest: StubGenerator.transactionRequest(),
                                             transactionConsumer: self.mockTransactionConsumer,
                                             walletLoader: self.mockWalletLoader)
    }

    override func tearDown() {
        self.mockWalletLoader = nil
        self.mockTransactionConsumer = nil
        self.sut = nil
        super.tearDown()
    }

    func testLoadWalletsCallWalletCallbacks() {
        self.sut.loadWallets()
        XCTAssert(self.mockWalletLoader.isLoadWalletCalled)
    }

    func testLoadWalletsFailed() {
        var didFail = false
        self.sut.onFailedLoadWallet = {
            XCTAssertEqual($0.message, "unexpected error: Failed to load wallets")
            didFail = true
        }
        self.sut.loadWallets()
        let error: OMGError = .unexpected(message: "Failed to load wallets")
        self.mockWalletLoader.loadAllWalletsFailed(withError: error)
        XCTAssert(didFail)
    }

    func testLoadWalletsSucceed() {
        var didLoadWallets = false
        self.sut.onSuccessGetWallets = { didLoadWallets = true }
        self.goToLoadFinished()
        XCTAssert(didLoadWallets)
    }

    func testShowLoadingWhenLoadingData() {
        let dispatchExpectation = expectation(description: "Wait for dispatch")
        var loadingStatus = false
        self.sut.onLoadStateChange = { loadingStatus = $0 }
        self.mockWalletLoader.wallets = [StubGenerator.mainWallet()]
        self.sut.loadWallets()
        XCTAssertTrue(loadingStatus)
        self.mockWalletLoader.loadAllWalletsSuccess()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            dispatchExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.3)
        XCTAssertFalse(loadingStatus)
    }

    func testConsumeCalled() {
        self.sut.consumeTransactionRequest()
        XCTAssert(self.mockTransactionConsumer.isConsumeCalled)
    }

    func testConsumeFailed() {
        var didFail = false
        self.sut.onFailedConsume = {
            XCTAssertEqual($0.message, "unexpected error: Failed to consume transaction")
            didFail = true
        }
        self.sut.consumeTransactionRequest()
        let error: OMGError = .unexpected(message: "Failed to consume transaction")
        self.mockTransactionConsumer.consumeTransactionFailed(withError: error)
        XCTAssert(didFail)
    }

    func testConsumeSucceed() {
        var didConsume = false
        self.sut.onSuccessConsume = { _ in didConsume = true }
        self.goToConsumeTransactionRequestFinished()
        XCTAssert(didConsume)
    }

    func testPickerData() {
        self.goToLoadFinished()
        XCTAssertEqual(self.sut.numberOfRows(inPicker: .address), 1)
        XCTAssertEqual(self.sut.title(forRow: 0, picker: .address), "XXX123")
        XCTAssertEqual(self.sut.numberOfColumnsInPicker(), 1)
    }

    func testShowLoadingConsuming() {
        var loadingStatus = false
        self.sut.onLoadStateChange = { loadingStatus = $0 }
        self.mockTransactionConsumer.transactionConsume = StubGenerator.transactionConsumption()
        self.sut.consumeTransactionRequest()
        XCTAssertTrue(loadingStatus)
        self.mockTransactionConsumer.consumeTransactionSuccess()
        XCTAssertFalse(loadingStatus)
    }
}

extension TRequestConsumerViewModelTests {
    private func goToLoadFinished() {
        self.mockWalletLoader.wallets = [StubGenerator.mainWallet()]
        self.sut.loadWallets()
        self.mockWalletLoader.loadAllWalletsSuccess()
    }

    private func goToConsumeTransactionRequestFinished() {
        self.mockTransactionConsumer.transactionConsume = StubGenerator.transactionConsumption()
        self.sut.consumeTransactionRequest()
        self.mockTransactionConsumer.consumeTransactionSuccess()
    }
}
