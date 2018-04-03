//
//  QRCodeGeneratorViewModel.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 16/2/18.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

import XCTest
@testable import OMGShop
import OmiseGO

class QRCodeGeneratorViewModelTests: XCTestCase {

    var mockSettingLoader: MockSettingLoader!
    var mockTransactionRequestCreator: MockTransactionRequestCreator!
    var mockTransactionConsumer: MockTransactionConsumer!
    var sut: QRCodeGeneratorViewModel!

    override func setUp() {
        super.setUp()
        self.mockSettingLoader = MockSettingLoader()
        self.mockTransactionRequestCreator = MockTransactionRequestCreator()
        self.mockTransactionConsumer = MockTransactionConsumer()
        self.sut = QRCodeGeneratorViewModel(settingLoader: self.mockSettingLoader,
                                            transactionRequestCreator: self.mockTransactionRequestCreator,
                                            transactionConsumer: self.mockTransactionConsumer)
    }

    override func tearDown() {
        self.mockSettingLoader = nil
        self.mockTransactionRequestCreator = nil
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

    func testGenerateTransactionRequestCalledIfMintedTokenIsNotNil() {
        self.goToLoadSettingsFinished()
        self.sut.generate()
        XCTAssert(self.mockTransactionRequestCreator.isGenerateCalled)
    }

    func testGenerateTransactionRequestFailed() {
        self.goToLoadSettingsFinished()
        var didFail = false
        self.sut.onFailedGenerate = {
            XCTAssertEqual($0.message, "unexpected error: Failed to generate transaction request")
            didFail = true
        }
        self.sut.generate()
        let error: OMGError = .unexpected(message: "Failed to generate transaction request")
        self.mockTransactionRequestCreator.generateTransactionRequestFailed(withError: error)
        XCTAssert(didFail)
    }

    func testGenerateTransactionRequestSucceed() {
        var didGenerate = false
        self.sut.onSuccessGenerate = { _ in didGenerate = true }
        self.goToGenerateTransactionRequestFinished()
        XCTAssert(didGenerate)
    }

    func testShowLoadingWhenGenerating() {
        self.goToLoadSettingsFinished()
        var loadingStatus = false
        self.sut.onLoadStateChange = { loadingStatus = $0 }
        self.mockTransactionRequestCreator.transactionRequest = StubGenerator.transactionRequest()
        self.sut.generate()
        XCTAssertTrue(loadingStatus)
        self.mockTransactionRequestCreator.generateTransactionRequestSuccess()
        XCTAssertFalse(loadingStatus)
    }

    func testConsumeCalled() {
        self.sut.consume(transactionRequest: StubGenerator.transactionRequest())
        XCTAssert(self.mockTransactionConsumer.isConsumeCalled)
    }

    func testConsumeFailed() {
        var didFail = false
        self.sut.onFailedConsume = {
            XCTAssertEqual($0.message, "unexpected error: Failed to consume transaction")
            didFail = true
        }
        self.sut.consume(transactionRequest: StubGenerator.transactionRequest())
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
        self.mockTransactionConsumer.transactionConsume = StubGenerator.transactionConsume()
        self.sut.consume(transactionRequest: StubGenerator.transactionRequest())
        XCTAssertTrue(loadingStatus)
        self.mockTransactionConsumer.consumeTransactionSuccess()
        XCTAssertFalse(loadingStatus)
    }

    func testPickerData() {
        self.goToLoadSettingsFinished()
        XCTAssertEqual(self.sut.numberOfRowsInPicker(), 2)
        XCTAssertEqual(self.sut.numberOfColumnsInPicker(), 1)
        XCTAssertEqual(self.sut.title(forRow: 0), "OmiseGO")
        XCTAssertEqual(self.sut.title(forRow: 1), "Bitcoin")
    }

    func testGenerateButtonState() {
        var isGenerateButtonEnabled = self.sut.isGenerateButtonEnabled
        self.sut.onGenerateButtonStateChange = { isGenerateButtonEnabled = $0 }
        XCTAssertFalse(isGenerateButtonEnabled)
        self.goToLoadSettingsFinished()
        XCTAssertFalse(isGenerateButtonEnabled)
        self.sut.amountStr = "invalid number"
        XCTAssertFalse(isGenerateButtonEnabled)
        self.sut.amountStr = "13.37"
        XCTAssertTrue(isGenerateButtonEnabled)
    }

}

extension QRCodeGeneratorViewModelTests {

    private func goToLoadSettingsFinished() {
        self.mockSettingLoader.settings = StubGenerator.settings()
        self.sut.loadSettings()
        self.mockSettingLoader.loadSettingSuccess()
    }

    private func goToGenerateTransactionRequestFinished() {
        self.goToLoadSettingsFinished()
        self.mockTransactionRequestCreator.transactionRequest = StubGenerator.transactionRequest()
        self.sut.generate()
        self.mockTransactionRequestCreator.generateTransactionRequestSuccess()
    }

    private func goToConsumeTransactionRequestFinished() {
        self.mockTransactionConsumer.transactionConsume = StubGenerator.transactionConsume()
        self.sut.consume(transactionRequest: StubGenerator.transactionRequest())
        self.mockTransactionConsumer.consumeTransactionSuccess()
    }

}
