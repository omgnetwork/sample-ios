//
//  TRequestConsumerViewModelTests.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 10/4/18.
//  Copyright © 2018 Omise Go Ptd. Ltd. All rights reserved.
//

import XCTest
@testable import OMGShop
import OmiseGO

class TRequestConsumerViewModelTests: XCTestCase {

    var mockSettingLoader: MockSettingLoader!
    var mockTransactionConsumer: MockTransactionConsumer!
    var mockWalletLoader: MockWalletLoader!
    var sut: TRequestConsumerViewModel!

    override func setUp() {
        super.setUp()
        self.mockSettingLoader = MockSettingLoader()
        self.mockTransactionConsumer = MockTransactionConsumer()
        self.mockWalletLoader = MockWalletLoader()
        self.sut = TRequestConsumerViewModel(transactionRequest: StubGenerator.transactionRequest(),
                                             transactionConsumer: self.mockTransactionConsumer,
                                             walletLoader: self.mockWalletLoader,
                                             settingLoader: self.mockSettingLoader)
    }

    override func tearDown() {
        self.mockSettingLoader = nil
        self.mockWalletLoader = nil
        self.mockTransactionConsumer = nil
        self.sut = nil
        super.tearDown()
    }

    func testLoadCallSettingAndAddressCallbacks() {
        self.sut.loadData()
        XCTAssert(self.mockSettingLoader.isLoadSettingCalled)
        XCTAssert(self.mockWalletLoader.isLoadWalletCalled)
    }

    func testLoadSettingsFailed() {
        var didFail = false
        self.sut.onFailedGetSettings = {
            XCTAssertEqual($0.message, "unexpected error: Failed to load settings")
            didFail = true
        }
        self.sut.loadData()
        let error: OMGError = .unexpected(message: "Failed to load settings")
        self.mockSettingLoader.loadSettingFailed(withError: error)
        XCTAssert(didFail)
    }

    func testLoadSettingsSucceed() {
        var didLoadSettings = false
        self.sut.onSuccessGetSettings = { didLoadSettings = true }
        self.goToLoadFinished()
        XCTAssert(didLoadSettings)

    }

    func testLoadWalletsFailed() {
        var didFail = false
        self.sut.onFailedLoadWallet = {
            XCTAssertEqual($0.message, "unexpected error: Failed to load wallets")
            didFail = true
        }
        self.sut.loadData()
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
        self.mockSettingLoader.settings = StubGenerator.settings()
        self.mockWalletLoader.wallets = [StubGenerator.mainWallet()]
        self.sut.loadData()
        XCTAssertTrue(loadingStatus)
        self.mockSettingLoader.loadSettingSuccess()
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
        XCTAssertEqual(self.sut.numberOfRows(inPicker: .token), 2)
        XCTAssertEqual(self.sut.numberOfColumnsInPicker(), 1)
        XCTAssertEqual(self.sut.title(forRow: 0, picker: .token), "OmiseGO")
        XCTAssertEqual(self.sut.title(forRow: 1, picker: .token), "Bitcoin")
        XCTAssertEqual(self.sut.title(forRow: 0, picker: .address), "XXX123")
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
        self.mockSettingLoader.settings = StubGenerator.settings()
        self.sut.loadData()
        self.mockSettingLoader.loadSettingSuccess()
        self.mockWalletLoader.loadAllWalletsSuccess()
    }

    private func goToConsumeTransactionRequestFinished() {
        self.mockTransactionConsumer.transactionConsume = StubGenerator.transactionConsumption()
        self.sut.consumeTransactionRequest()
        self.mockTransactionConsumer.consumeTransactionSuccess()
    }

}
