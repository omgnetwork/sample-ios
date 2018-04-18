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
    var mockAddressLoader: MockAddressLoader!
    var sut: TRequestConsumerViewModel!

    override func setUp() {
        super.setUp()
        self.mockSettingLoader = MockSettingLoader()
        self.mockTransactionConsumer = MockTransactionConsumer()
        self.mockAddressLoader = MockAddressLoader()
        self.sut = TRequestConsumerViewModel(transactionRequest: StubGenerator.transactionRequest(),
                                             transactionConsumer: self.mockTransactionConsumer,
                                             addressLoader: self.mockAddressLoader,
                                             settingLoader: self.mockSettingLoader)
    }

    override func tearDown() {
        self.mockSettingLoader = nil
        self.mockAddressLoader = nil
        self.mockTransactionConsumer = nil
        self.sut = nil
        super.tearDown()
    }

    func testLoadCallSettingAndAddressCallbacks() {
        self.sut.loadData()
        XCTAssert(self.mockSettingLoader.isLoadSettingCalled)
        XCTAssert(self.mockAddressLoader.isLoadAddressCalled)
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

    func testLoadAddressesFailed() {
        var didFail = false
        self.sut.onFailedLoadAddress = {
            XCTAssertEqual($0.message, "unexpected error: Failed to load addresses")
            didFail = true
        }
        self.sut.loadData()
        let error: OMGError = .unexpected(message: "Failed to load addresses")
        self.mockAddressLoader.loadAllAddressesFailed(withError: error)
        XCTAssert(didFail)
    }

    func testLoadAddressesSucceed() {
        var didLoadAddresses = false
        self.sut.onSuccessGetAddresses = { didLoadAddresses = true }
        self.goToLoadFinished()
        XCTAssert(didLoadAddresses)
    }

    func testShowLoadingWhenLoadingData() {
        let dispatchExpectation = expectation(description: "Wait for dispatch")
        var loadingStatus = false
        self.sut.onLoadStateChange = { loadingStatus = $0 }
        self.mockSettingLoader.settings = StubGenerator.settings()
        self.mockAddressLoader.addresses = [StubGenerator.mainAddress()]
        self.sut.loadData()
        XCTAssertTrue(loadingStatus)
        self.mockSettingLoader.loadSettingSuccess()
        XCTAssertTrue(loadingStatus)
        self.mockAddressLoader.loadAllAddressesSuccess()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            dispatchExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.1)
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
        XCTAssertEqual(self.sut.numberOfRows(inPicker: .mintedToken), 2)
        XCTAssertEqual(self.sut.numberOfColumnsInPicker(), 1)
        XCTAssertEqual(self.sut.title(forRow: 0, picker: .mintedToken), "OmiseGO")
        XCTAssertEqual(self.sut.title(forRow: 1, picker: .mintedToken), "Bitcoin")
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
        self.mockAddressLoader.addresses = [StubGenerator.mainAddress()]
        self.mockSettingLoader.settings = StubGenerator.settings()
        self.sut.loadData()
        self.mockSettingLoader.loadSettingSuccess()
        self.mockAddressLoader.loadAllAddressesSuccess()
    }

    private func goToConsumeTransactionRequestFinished() {
        self.mockTransactionConsumer.transactionConsume = StubGenerator.transactionConsumption()
        self.sut.consumeTransactionRequest()
        self.mockTransactionConsumer.consumeTransactionSuccess()
    }

}
