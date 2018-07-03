//
//  ProfileViewModelTests.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 21/11/17.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

@testable import OMGShop
import OmiseGO
import XCTest

class ProfileViewModelTests: XCTestCase {
    var mockWalletLoader: MockWalletLoader!
    var mockSessionManager: MockSessionManager!
    var sut: ProfileViewModel!

    override func setUp() {
        super.setUp()
        self.mockWalletLoader = MockWalletLoader()
        self.mockSessionManager = MockSessionManager()
        self.sut = ProfileViewModel(sessionManager: self.mockSessionManager, walletLoader: self.mockWalletLoader)
        TokenManager.shared.selectedTokenSymbol = nil
    }

    override func tearDown() {
        self.mockWalletLoader = nil
        self.mockSessionManager = nil
        self.sut = nil
        TokenManager.shared.selectedTokenSymbol = nil
        super.tearDown()
    }

    func testLoadCalled() {
        self.sut.loadData()
        XCTAssert(self.mockWalletLoader.isLoadWalletCalled)
        XCTAssert(self.mockSessionManager.isLoadCurrentUserCalled)
    }

    func testLoadWalletFailed() {
        var didFail = false
        self.sut.onFailGetWallet = {
            XCTAssertEqual($0.message, "unexpected error: Failed to load wallet")
            didFail = true
        }
        self.sut.loadData()
        let error: OMGError = .unexpected(message: "Failed to load wallet")
        self.mockWalletLoader.loadMainWalletFailed(withError: error)
        self.mockSessionManager.loadCurrentUserSuccess()
        XCTAssert(didFail)
    }

    func testLoadCurrentUserFailed() {
        var didFail = false
        self.sut.onFailReloadUser = {
            XCTAssertEqual($0.message, "unexpected error: Failed to load user")
            didFail = true
        }
        self.sut.loadData()
        let error: OMGError = .unexpected(message: "Failed to load user")
        self.mockWalletLoader.wallet = StubGenerator.mainWallet()
        self.mockWalletLoader.loadMainWalletSuccess()
        self.mockSessionManager.loadCurrentUserFailed(withError: error)
        XCTAssert(didFail)
    }

    func testLoadSucceed() {
        var didLoadCurrentUser = false
        var didLoadWallet = false
        self.sut.onSuccessReloadUser = {
            XCTAssertEqual($0, self.mockSessionManager.currentUser!.username)
            didLoadCurrentUser = true
        }
        self.sut.onTableDataChange = { didLoadWallet = true }
        self.goToLoadFinished()
        XCTAssert(didLoadCurrentUser)
        XCTAssert(didLoadWallet)
        XCTAssertEqual(TokenManager.shared.selectedTokenSymbol,
                       self.mockWalletLoader.wallet!.balances[0].token.symbol)
    }

    func testGetCellViewModel() {
        self.goToLoadFinished()
        XCTAssert(self.sut.numberOfRow() == self.mockWalletLoader.wallet!.balances.count)
        let indexPath = IndexPath(row: 0, section: 0)
        let cellViewModel = self.sut.cellViewModel(forIndex: indexPath.row)
        XCTAssertEqual(cellViewModel.tokenSymbol, self.mockWalletLoader.wallet!.balances.first!.token.symbol)
    }

    func testCellViewModel() {
        let balance = StubGenerator.mainWallet().balances.first!
        let cellViewModel = TokenCellViewModel(balance: balance, isSelected: true)
        XCTAssertEqual(cellViewModel.isSelected, true)
        XCTAssertEqual(cellViewModel.tokenAmount, balance.displayAmount(withPrecision: 2))
        XCTAssertEqual(cellViewModel.tokenSymbol, balance.token.symbol)
    }

    func testCellViewModelSelection() {
        self.goToLoadFinished()
        self.sut.didSelectToken(atIndex: 0)
        XCTAssertTrue(self.sut.cellViewModel(forIndex: 0).isSelected)
        XCTAssertFalse(self.sut.cellViewModel(forIndex: 1).isSelected)
        XCTAssertEqual(TokenManager.shared.selectedTokenSymbol,
                       self.mockWalletLoader.wallet!.balances[0].token.symbol)
        self.sut.didSelectToken(atIndex: 1)
        XCTAssertTrue(self.sut.cellViewModel(forIndex: 1).isSelected)
        XCTAssertFalse(self.sut.cellViewModel(forIndex: 0).isSelected)
        XCTAssertEqual(TokenManager.shared.selectedTokenSymbol,
                       self.mockWalletLoader.wallet!.balances[1].token.symbol)
    }

    func testLoadingWhenLoading() {
        var loadingStatus = false
        self.sut.onLoadStateChange = { loadingStatus = $0 }
        self.mockWalletLoader.wallet = StubGenerator.mainWallet()
        self.mockSessionManager.currentUser = StubGenerator.stubCurrentUser()
        self.sut.loadData()
        XCTAssertTrue(loadingStatus)
        self.mockWalletLoader.loadMainWalletSuccess()
        self.mockSessionManager.loadCurrentUserSuccess()
        XCTAssertFalse(loadingStatus)
    }

    func testLogoutCalled() {
        self.sut.logout()
        XCTAssert(self.mockSessionManager.isLogoutCalled)
    }

    func testLogoutFailed() {
        let expectation = self.expectation(description: "Logout should fail")
        var didFail = false
        self.sut.onFailLogout = {
            XCTAssertEqual($0.message, "Error")
            didFail = true
            expectation.fulfill()
        }
        self.sut.logout()
        self.mockSessionManager.logoutFailed(withError: .init(code: .other("Error"), description: "Error"))
        self.wait(for: [expectation], timeout: 1)
        XCTAssert(didFail)
    }

    func testLogoutSucceed() {
        let expectation = self.expectation(description: "Logout should fail")
        var didLogout = false
        self.sut.onLogoutSuccess = {
            didLogout = true
            expectation.fulfill()
        }
        self.sut.logout()
        self.mockSessionManager.logoutSuccess()
        self.wait(for: [expectation], timeout: 1)
        XCTAssert(didLogout)
    }
}

extension ProfileViewModelTests {
    private func goToLoadFinished() {
        self.mockWalletLoader.wallet = StubGenerator.mainWallet()
        self.mockSessionManager.currentUser = StubGenerator.stubCurrentUser()
        self.sut.loadData()
        self.mockWalletLoader.loadMainWalletSuccess()
        self.mockSessionManager.loadCurrentUserSuccess()
    }
}
