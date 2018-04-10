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
    var sut: TRequestConsumerViewModel!

    override func setUp() {
        super.setUp()
        self.mockSettingLoader = MockSettingLoader()
        self.mockTransactionConsumer = MockTransactionConsumer()
        self.sut = TRequestConsumerViewModel(transactionRequest: StubGenerator.transactionRequest(),
                                             transactionConsumer: self.mockTransactionConsumer,
                                             settingLoader: self.mockSettingLoader)
    }

    override func tearDown() {
        self.mockSettingLoader = nil
        self.mockTransactionConsumer = nil
        self.sut = nil
        super.tearDown()
    }

    func testLoadSettingsCalled() {
        self.sut.loadSettings()
        XCTAssert(self.mockSettingLoader.isLoadSettingCalled)
    }

    func testLoadSettingsFailed() {
        var didFail = false
        self.sut.onFailedGetSettings = {
            XCTAssertEqual($0.message, "unexpected error: Failed to load settings")
            didFail = true
        }
        self.sut.loadSettings()
        let error: OMGError = .unexpected(message: "Failed to load settings")
        self.mockSettingLoader.loadSettingFailed(withError: error)
        XCTAssert(didFail)
    }

    func testLoadSettingsSucceed() {
        var didLoadSettings = false
        self.sut.onSuccessGetSettings = { didLoadSettings = true }
        self.goToLoadSettingsFinished()
        XCTAssert(didLoadSettings)

    }

    func testShowLoadingWhenLoadingSettings() {
        var loadingStatus = false
        self.sut.onLoadStateChange = { loadingStatus = $0 }
        self.mockSettingLoader.settings = StubGenerator.settings()
        self.sut.loadSettings()
        XCTAssertTrue(loadingStatus)
        self.mockSettingLoader.loadSettingSuccess()
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

    private func goToLoadSettingsFinished() {
        self.mockSettingLoader.settings = StubGenerator.settings()
        self.sut.loadSettings()
        self.mockSettingLoader.loadSettingSuccess()
    }

    private func goToConsumeTransactionRequestFinished() {
        self.mockTransactionConsumer.transactionConsume = StubGenerator.transactionConsumption()
        self.sut.consumeTransactionRequest()
        self.mockTransactionConsumer.consumeTransactionSuccess()
    }

}
