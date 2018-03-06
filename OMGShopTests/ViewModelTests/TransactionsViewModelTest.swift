//
//  TransactionsViewModelTest.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 6/3/18.
//  Copyright © 2018 Mederic Petit. All rights reserved.
//

import XCTest
import OmiseGO
@testable import OMGShop

class TransactionsViewModelTest: XCTestCase {

    var mockTransactionLoader: MockTransactionLoader!
    var sut: TransactionsViewModel!
    let address = "083fe98d-a1f4-4fe9-bac0-b967b83140fc"

    override func setUp() {
        super.setUp()
        self.mockTransactionLoader = MockTransactionLoader()
        self.sut = TransactionsViewModel(transactionLoader: self.mockTransactionLoader,
                                         address: self.address)
    }

    override func tearDown() {
        self.mockTransactionLoader = nil
        self.sut = nil
        super.tearDown()
    }

    func testReloadTransactions() {
        self.sut.reloadTransactions()
        XCTAssert(self.mockTransactionLoader.isListCalled)
    }

    func testGetNextTransactionsCalled() {
        self.sut.getNextTransactions()
        XCTAssert(self.mockTransactionLoader.isListCalled)
    }

    func testGetNextTransactionsFailed() {
        var didFail = false
        self.sut.onFailLoadTransactions = {
            XCTAssertEqual($0.message, "unexpected error: Failed to load transactions")
            didFail = true
        }
        self.sut.getNextTransactions()
        let error: OmiseGOError = .unexpected(message: "Failed to load transactions")
        self.mockTransactionLoader.loadTransactionFailed(withError: error)
        XCTAssert(didFail)
    }

    func testGetNextTransactionsSucceed() {
        var expectedIndexPaths: [IndexPath] = []
        self.sut.appendNewResultClosure = { indexPaths in
            expectedIndexPaths = indexPaths
        }
        self.goToLoadTransactionsFinished()
        XCTAssertFalse(expectedIndexPaths.isEmpty)
    }

    func testGetCellViewModel() {
        self.goToLoadTransactionsFinished()
        XCTAssert(self.sut.numberOfRow() == self.mockTransactionLoader.transactions!.count)
        let indexPath = IndexPath(row: 0, section: 0)
        let cellViewModel = self.sut.transactionCellViewModel(at: indexPath)
        XCTAssertEqual(cellViewModel.address, self.mockTransactionLoader.transactions!.first!.to.address)
    }

    func testCellViewModel() {
        let transactionDebit = StubGenerator.stubTransactions()[0]
        let cellViewModelDebit = TransactionCellViewModel(transaction: transactionDebit,
                                                          currentUserAddress: self.address)
        XCTAssertEqual(cellViewModelDebit.address, "XXX123")
        XCTAssertEqual(cellViewModelDebit.amount, "- 10.0 ABC")
        XCTAssertEqual(cellViewModelDebit.color, Color.transactionDebit.uiColor())
        XCTAssertEqual(cellViewModelDebit.direction, "transactions.label.to".localized())
        XCTAssertEqual(cellViewModelDebit.timeStamp, "01 Jan 2018 07:00:00")
        let transactionCredit = StubGenerator.stubTransactions()[1]
        let cellViewModelCredit = TransactionCellViewModel(transaction: transactionCredit,
                                                           currentUserAddress: self.address)
        XCTAssertEqual(cellViewModelCredit.address, "XXX123")
        XCTAssertEqual(cellViewModelCredit.amount, "+ 10.0 ABC")
        XCTAssertEqual(cellViewModelCredit.color, Color.transactionCredit.uiColor())
        XCTAssertEqual(cellViewModelCredit.direction, "transactions.label.from".localized())
        XCTAssertEqual(cellViewModelCredit.timeStamp, "01 Jan 2018 07:00:00")
    }

    func testLoadingWhenRequesting() {
        var loadingStatus = false
        self.sut.onLoadStateChange = { loadingStatus = $0 }
        self.mockTransactionLoader.transactions = StubGenerator.stubTransactions()
        self.mockTransactionLoader.pagination = StubGenerator.stubPagination()
        self.sut.getNextTransactions()
        XCTAssertTrue(loadingStatus)
        self.mockTransactionLoader.loadTransactionSuccess()
        XCTAssertFalse(loadingStatus)
    }

}

extension TransactionsViewModelTest {

    private func goToLoadTransactionsFinished() {
        self.mockTransactionLoader.transactions = StubGenerator.stubTransactions()
        self.mockTransactionLoader.pagination = StubGenerator.stubPagination()
        self.sut.getNextTransactions()
        self.mockTransactionLoader.loadTransactionSuccess()
    }

}
