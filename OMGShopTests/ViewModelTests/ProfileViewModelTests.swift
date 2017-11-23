//
//  ProfileViewModelTests.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 21/11/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import XCTest
@testable import OMGShop
import OmiseGO

class ProfileViewModelTests: XCTestCase {

    var mockAddressLoader: MockAddressLoader!
    var mockSessionManager: MockSessionManager!
    var sut: ProfileViewModel!

    override func setUp() {
        super.setUp()
        self.mockAddressLoader = MockAddressLoader()
        self.mockSessionManager = MockSessionManager()
        self.sut = ProfileViewModel(sessionManager: self.mockSessionManager, addressLoader: self.mockAddressLoader)
        MintedTokenManager.shared.selectedTokenSymbol = nil
    }

    override func tearDown() {
        self.mockAddressLoader = nil
        self.mockSessionManager = nil
        self.sut = nil
        MintedTokenManager.shared.selectedTokenSymbol = nil
        super.tearDown()
    }

    func testLoadCalled() {
        self.sut.loadData()
        XCTAssert(self.mockAddressLoader.isLoadAddressCalled)
        XCTAssert(self.mockSessionManager.isLoadCurrentUserCalled)
    }

    func testLoadAddressFailed() {
        var didFail = false
        self.sut.onFailGetAddress = {
            XCTAssertEqual($0.message, "unexpected error: Failed to load address")
            didFail = true
        }
        self.sut.loadData()
        let error: OmiseGOError = .unexpected(message: "Failed to load address")
        self.mockAddressLoader.loadMainAddressFailed(withError: error)
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
        let error: OmiseGOError = .unexpected(message: "Failed to load user")
        self.mockAddressLoader.address = StubGenerator().mainAddress()
        self.mockAddressLoader.loadMainAddressSuccess()
        self.mockSessionManager.loadCurrentUserFailed(withError: error)
        XCTAssert(didFail)
    }

    func testLoadSucceed() {
        var didLoadCurrentUser = false
        var didLoadAddress = false
        self.sut.onSuccessReloadUser = {
            XCTAssertEqual($0, self.mockSessionManager.currentUser!.username)
            didLoadCurrentUser = true
        }
        self.sut.onTableDataChange = { didLoadAddress = true }
        self.goToLoadFinished()
        XCTAssert(didLoadCurrentUser)
        XCTAssert(didLoadAddress)
        XCTAssertEqual(MintedTokenManager.shared.selectedTokenSymbol,
                       self.mockAddressLoader.address!.balances[0].mintedToken.symbol)

    }

    func testGetCellViewModel() {
        self.goToLoadFinished()
        XCTAssert(self.sut.numberOfRow() == self.mockAddressLoader.address!.balances.count)
        let indexPath = IndexPath(row: 0, section: 0)
        let cellViewModel = self.sut.cellViewModel(forIndex: indexPath.row)
        XCTAssertEqual(cellViewModel.tokenSymbol, self.mockAddressLoader.address!.balances.first!.mintedToken.symbol)
    }

    func testCellViewModel() {
        let balance = StubGenerator().mainAddress().balances.first!
        let cellViewModel = TokenCellViewModel(balance: balance, isSelected: true)
        XCTAssertEqual(cellViewModel.isSelected, true)
        XCTAssertEqual(cellViewModel.tokenAmount, balance.displayAmount(withPrecision: 2))
        XCTAssertEqual(cellViewModel.tokenSymbol, balance.mintedToken.symbol)
    }

    func testCellViewModelSelection() {
        self.goToLoadFinished()
        self.sut.didSelectToken(atIndex: 0)
        XCTAssertTrue(self.sut.cellViewModel(forIndex: 0).isSelected)
        XCTAssertFalse(self.sut.cellViewModel(forIndex: 1).isSelected)
        XCTAssertEqual(MintedTokenManager.shared.selectedTokenSymbol,
                       self.mockAddressLoader.address!.balances[0].mintedToken.symbol)
        self.sut.didSelectToken(atIndex: 1)
        XCTAssertTrue(self.sut.cellViewModel(forIndex: 1).isSelected)
        XCTAssertFalse(self.sut.cellViewModel(forIndex: 0).isSelected)
        XCTAssertEqual(MintedTokenManager.shared.selectedTokenSymbol,
                       self.mockAddressLoader.address!.balances[1].mintedToken.symbol)
    }

    func testLoadingWhenLoading() {
        var loadingStatus = false
        self.sut.onLoadStateChange = { loadingStatus = $0 }
        self.mockAddressLoader.address = StubGenerator().mainAddress()
        self.mockSessionManager.currentUser = StubGenerator().stubCurrentUser()
        self.sut.loadData()
        XCTAssertTrue(loadingStatus)
        self.mockAddressLoader.loadMainAddressSuccess()
        self.mockSessionManager.loadCurrentUserSuccess()
        XCTAssertFalse(loadingStatus)
    }

    func testLogoutCalled() {
        self.sut.logout()
        XCTAssert(self.mockSessionManager.isLogoutCalled)
    }

    func testLogoutFailed() {
        let e = self.expectation(description: "Logout should fail")
        var didFail = false
        self.sut.onFailLogout = {
            XCTAssertEqual($0.message, "Error")
            didFail = true
            e.fulfill()
        }
        self.sut.logout()
        self.mockSessionManager.logoutFailed(withError: .init(code: .other("Error"), description: "Error"))
        self.wait(for: [e], timeout: 1)
        XCTAssert(didFail)
    }

    func testLogoutSucceed() {
        let e = self.expectation(description: "Logout should fail")
        var didLogout = false
        self.sut.onLogoutSuccess = {
            didLogout = true
            e.fulfill()
        }
        self.sut.logout()
        self.mockSessionManager.logoutSuccess()
        self.wait(for: [e], timeout: 1)
        XCTAssert(didLogout)
    }

}

extension ProfileViewModelTests {

    private func goToLoadFinished() {
        self.mockAddressLoader.address = StubGenerator().mainAddress()
        self.mockSessionManager.currentUser = StubGenerator().stubCurrentUser()
        self.sut.loadData()
        self.mockAddressLoader.loadMainAddressSuccess()
        self.mockSessionManager.loadCurrentUserSuccess()
    }

}
