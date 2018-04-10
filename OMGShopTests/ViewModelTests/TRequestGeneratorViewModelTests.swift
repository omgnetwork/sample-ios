//
//  TRequestGenerator.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 16/2/18.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

import XCTest
@testable import OMGShop
import OmiseGO

class TRequestGeneratorViewModelTests: XCTestCase {

    var mockSettingLoader: MockSettingLoader!
    var mockTransactionRequestCreator: MockTransactionRequestCreator!
    var sut: TRequestGeneratorViewModel!

    override func setUp() {
        super.setUp()
        self.mockSettingLoader = MockSettingLoader()
        self.mockTransactionRequestCreator = MockTransactionRequestCreator()
        self.sut = TRequestGeneratorViewModel(settingLoader: self.mockSettingLoader,
                                            transactionRequestCreator: self.mockTransactionRequestCreator)
    }

    override func tearDown() {
        self.mockSettingLoader = nil
        self.mockTransactionRequestCreator = nil
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
        self.sut.generateTransactionRequest()
        XCTAssert(self.mockTransactionRequestCreator.isGenerateCalled)
    }

    func testGenerateTransactionRequestFailed() {
        self.goToLoadSettingsFinished()
        var didFail = false
        self.sut.onFailedGenerate = {
            XCTAssertEqual($0.message, "unexpected error: Failed to generate transaction request")
            didFail = true
        }
        self.sut.generateTransactionRequest()
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
        self.sut.generateTransactionRequest()
        XCTAssertTrue(loadingStatus)
        self.mockTransactionRequestCreator.generateTransactionRequestSuccess()
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
        XCTAssertTrue(isGenerateButtonEnabled)
    }

}

extension TRequestGeneratorViewModelTests {

    private func goToLoadSettingsFinished() {
        self.mockSettingLoader.settings = StubGenerator.settings()
        self.sut.loadSettings()
        self.mockSettingLoader.loadSettingSuccess()
    }

    private func goToGenerateTransactionRequestFinished() {
        self.goToLoadSettingsFinished()
        self.mockTransactionRequestCreator.transactionRequest = StubGenerator.transactionRequest()
        self.sut.generateTransactionRequest()
        self.mockTransactionRequestCreator.generateTransactionRequestSuccess()
    }

}
