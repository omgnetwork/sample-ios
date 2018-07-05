//
//  TRequestGenerator.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 16/2/18.
//  Copyright © 2017-2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import OMGShop
import OmiseGO
import XCTest

class TRequestGeneratorViewModelTests: XCTestCase {
    var mockSettingLoader: MockSettingLoader!
    var mockTransactionRequestCreator: MockTransactionRequestCreator!
    var mockWalletLoader: MockWalletLoader!
    var sut: TRequestGeneratorViewModel!

    override func setUp() {
        super.setUp()
        self.mockSettingLoader = MockSettingLoader()
        self.mockTransactionRequestCreator = MockTransactionRequestCreator()
        self.mockWalletLoader = MockWalletLoader()
        self.sut = TRequestGeneratorViewModel(settingLoader: self.mockSettingLoader,
                                              walletLoader: self.mockWalletLoader,
                                              transactionRequestCreator: self.mockTransactionRequestCreator)
    }

    override func tearDown() {
        self.mockSettingLoader = nil
        self.mockWalletLoader = nil
        self.mockTransactionRequestCreator = nil
        self.sut = nil
        super.tearDown()
    }

    func testLoadCallSettingAndWalletCallbacks() {
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            dispatchExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.1)
        XCTAssertFalse(loadingStatus)
    }

    func testGenerateTransactionRequestCalledIfMintedTokenIsNotNil() {
        self.goToLoadFinished()
        self.sut.generateTransactionRequest()
        XCTAssert(self.mockTransactionRequestCreator.isGenerateCalled)
    }

    func testGenerateTransactionRequestFailed() {
        self.goToLoadFinished()
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
        self.goToLoadFinished()
        var loadingStatus = false
        self.sut.onLoadStateChange = { loadingStatus = $0 }
        self.mockTransactionRequestCreator.transactionRequest = StubGenerator.transactionRequest()
        self.sut.generateTransactionRequest()
        XCTAssertTrue(loadingStatus)
        self.mockTransactionRequestCreator.generateTransactionRequestSuccess()
        XCTAssertFalse(loadingStatus)
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

    func testGenerateButtonState() {
        var isGenerateButtonEnabled = self.sut.isGenerateButtonEnabled
        self.sut.onGenerateButtonStateChange = { isGenerateButtonEnabled = $0 }
        XCTAssertFalse(isGenerateButtonEnabled)
        self.goToLoadFinished()
        XCTAssertTrue(isGenerateButtonEnabled)
    }
}

extension TRequestGeneratorViewModelTests {
    private func goToLoadFinished() {
        self.mockWalletLoader.wallets = [StubGenerator.mainWallet()]
        self.mockSettingLoader.settings = StubGenerator.settings()
        self.sut.loadData()
        self.mockSettingLoader.loadSettingSuccess()
        self.mockWalletLoader.loadAllWalletsSuccess()
    }

    private func goToGenerateTransactionRequestFinished() {
        self.goToLoadFinished()
        self.mockTransactionRequestCreator.transactionRequest = StubGenerator.transactionRequest()
        self.sut.generateTransactionRequest()
        self.mockTransactionRequestCreator.generateTransactionRequestSuccess()
    }
}
