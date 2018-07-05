//
//  TransactionsViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 5/3/18.
//  Copyright © 2017-2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO
import UIKit

class TransactionsViewModel: BaseViewModel {
    // Delegate closures
    var appendNewResultClosure: ObjectClosure<[IndexPath]>?
    var reloadTableViewClosure: EmptyClosure?
    var onFailLoadTransactions: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?

    let viewTitle: String = "transactions.view.title".localized()

    let myAddress: String
    let myAddressLabel = "transactions.label.my_address".localized()

    private var transactionCellViewModels: [TransactionCellViewModel]! = [] {
        didSet {
            if transactionCellViewModels.isEmpty { self.reloadTableViewClosure?() }
        }
    }

    var isLoading: Bool = false {
        didSet { self.onLoadStateChange?(self.isLoading) }
    }

    var paginator: TransactionPaginator!

    init(transactionLoader: TransactionLoaderProtocol = TransactionLoader(), address: String) {
        self.myAddress = address
        super.init()
        self.paginator = TransactionPaginator(transactionLoader: transactionLoader,
                                              address: address,
                                              successClosure: { [weak self] transactions in
                                                  self?.process(transactions)
                                                  self?.isLoading = false
                                              }, failureClosure: { [weak self] error in
                                                  self?.isLoading = false
                                                  self?.onFailLoadTransactions?(error)
        })
    }

    func reloadTransactions() {
        self.paginator.reset()
        self.transactionCellViewModels = []
        self.getNextTransactions()
    }

    func getNextTransactions() {
        self.isLoading = true
        self.paginator.loadNext()
    }

    private func process(_ transactions: [Transaction]) {
        var newCellViewModels: [TransactionCellViewModel] = []
        transactions.forEach({
            newCellViewModels.append(TransactionCellViewModel(transaction: $0,
                                                              currentUserAddress: self.paginator.address))
        })
        var indexPaths: [IndexPath] = []
        for row in
        self.transactionCellViewModels.count ..< (self.transactionCellViewModels.count + newCellViewModels.count) {
            indexPaths.append(IndexPath(row: row, section: 0))
        }
        self.transactionCellViewModels.append(contentsOf: newCellViewModels)
        self.appendNewResultClosure?(indexPaths)
    }
}

extension TransactionsViewModel {
    func transactionCellViewModel(at indexPath: IndexPath) -> TransactionCellViewModel {
        return self.transactionCellViewModels[indexPath.row]
    }

    func numberOfRow() -> Int {
        return self.transactionCellViewModels.count
    }

    func shouldLoadNext(atIndexPath indexPath: IndexPath) -> Bool {
        return self.numberOfRow() - indexPath.row < 5 && !self.paginator.reachedLastPage
    }
}
