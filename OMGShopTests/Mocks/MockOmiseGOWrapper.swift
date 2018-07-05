//
//  MockOmiseGOWrapper.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 21/11/17.
//  Copyright © 2017-2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import OMGShop
@testable import OmiseGO

class MockWalletLoader {
    var isLoadWalletCalled = false

    var wallet: Wallet?
    var wallets: [Wallet] = []
    var loadCompletionClosure: Wallet.RetrieveRequestCallback!
    var loadListCompletionClosure: Wallet.ListRequestCallback!

    func loadMainWalletSuccess() {
        self.loadCompletionClosure(OmiseGO.Response.success(data: self.wallet!))
    }

    func loadMainWalletFailed(withError error: OMGError) {
        self.loadCompletionClosure(OmiseGO.Response.fail(error: error))
    }

    func loadAllWalletsSuccess() {
        self.loadListCompletionClosure(OmiseGO.Response.success(data: self.wallets))
    }

    func loadAllWalletsFailed(withError error: OMGError) {
        self.loadListCompletionClosure(OmiseGO.Response.fail(error: error))
    }
}

extension MockWalletLoader: WalletLoaderProtocol {
    func getMain(withCallback callback: @escaping Wallet.RetrieveRequestCallback) {
        self.isLoadWalletCalled = true
        self.loadCompletionClosure = callback
    }

    func getAll(withCallback callback: @escaping Wallet.ListRequestCallback) {
        self.isLoadWalletCalled = true
        self.loadListCompletionClosure = callback
    }
}

class MockSettingLoader {
    var isLoadSettingCalled = false

    var settings: Setting?
    var loadCompletionClosure: Setting.RetrieveRequestCallback!

    func loadSettingSuccess() {
        self.loadCompletionClosure(OmiseGO.Response.success(data: self.settings!))
    }

    func loadSettingFailed(withError error: OMGError) {
        self.loadCompletionClosure(OmiseGO.Response.fail(error: error))
    }
}

extension MockSettingLoader: SettingLoaderProtocol {
    func get(withCallback callback: @escaping Setting.RetrieveRequestCallback) {
        self.isLoadSettingCalled = true
        self.loadCompletionClosure = callback
    }
}

class MockTransactionRequestCreator {
    var isGenerateCalled = false

    var transactionRequest: TransactionRequest?
    var generateCompletionClosure: TransactionRequest.RetrieveRequestCallback!

    func generateTransactionRequestSuccess() {
        self.generateCompletionClosure(OmiseGO.Response.success(data: self.transactionRequest!))
    }

    func generateTransactionRequestFailed(withError error: OMGError) {
        self.generateCompletionClosure(OmiseGO.Response.fail(error: error))
    }
}

extension MockTransactionRequestCreator: TransactionRequestCreateProtocol {
    func generate(withParams _: TransactionRequestCreateParams,
                  callback: @escaping TransactionRequest.RetrieveRequestCallback) {
        self.isGenerateCalled = true
        self.generateCompletionClosure = callback
    }
}

class MockTransactionConsumer {
    var isConsumeCalled = false

    var transactionConsume: TransactionConsumption?
    var consumeCompletionClosure: TransactionConsumption.RetrieveRequestCallback!

    func consumeTransactionSuccess() {
        self.consumeCompletionClosure(OmiseGO.Response.success(data: self.transactionConsume!))
    }

    func consumeTransactionFailed(withError error: OMGError) {
        self.consumeCompletionClosure(OmiseGO.Response.fail(error: error))
    }
}

extension MockTransactionConsumer: TransactionConsumeProtocol {
    func consume(withParams _: TransactionConsumptionParams,
                 callback: @escaping TransactionConsumption.RetrieveRequestCallback) {
        self.isConsumeCalled = true
        self.consumeCompletionClosure = callback
    }
}

class MockTransactionLoader {
    var isListCalled = false

    var transactions: [Transaction]?
    var pagination: Pagination?
    var completionClosure: Transaction.ListRequestCallback!

    func loadTransactionSuccess() {
        self.completionClosure(
            OmiseGO.Response.success(
                data: JSONPaginatedListResponse<Transaction>(data: self.transactions!, pagination: self.pagination!)
            )
        )
    }

    func loadTransactionFailed(withError error: OMGError) {
        self.completionClosure(OmiseGO.Response.fail(error: error))
    }
}

extension MockTransactionLoader: TransactionLoaderProtocol {
    func list(withParams _: TransactionListParams,
              callback: @escaping Transaction.ListRequestCallback)
        -> Transaction.ListRequest? {
        self.isListCalled = true
        self.completionClosure = callback
        return nil
    }
}
