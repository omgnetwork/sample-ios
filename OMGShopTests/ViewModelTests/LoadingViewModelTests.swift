//
//  LoadingViewModelTests.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 21/11/17.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

import XCTest
@testable import OMGShop

class LoadingViewModelTests: XCTestCase {

    var mockSessionManager: MockSessionManager!
    var sut: LoadingViewModel!

    override func setUp() {
        super.setUp()
        self.mockSessionManager = MockSessionManager()
        self.sut = LoadingViewModel(sessionManager: self.mockSessionManager)
    }

    override func tearDown() {
        self.mockSessionManager = nil
        self.sut = nil
        super.tearDown()
    }

    func testLoadCalled() {
        self.sut.load()
        XCTAssert(self.mockSessionManager.isLoadCurrentUserCalled)
    }

    func testLoadFailed() {
        var didFail = false
        self.sut.onFailedLoading = {
            XCTAssertEqual($0.message, "unexpected error: Failed to load user")
            didFail = true
        }
        self.sut.load()
        self.mockSessionManager.loadCurrentUserFailed(withError: .unexpected(message: "Failed to load user"))
        XCTAssert(didFail)
    }

    func testLoadSucceed() {
        var didCallAppStateChange = false
        self.sut.onAppStateChange = { didCallAppStateChange = true }
        self.sut.load()
        self.mockSessionManager.loadCurrentUserSuccess()
        XCTAssert(didCallAppStateChange)
    }

    func testLoadingWhenRequesting() {
        var loadingStatus = false
        self.sut.onLoadStateChange = { loadingStatus = $0 }
        self.sut.load()
        XCTAssertTrue(loadingStatus)
        self.mockSessionManager.loadCurrentUserSuccess()
        XCTAssertFalse(loadingStatus)
    }

}
