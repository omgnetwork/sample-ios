//
//  MockOmiseGOWrapper.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 21/11/17.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

@testable import OMGShop
import OmiseGO

class MockAddressLoader {

    var isLoadAddressCalled = false

    var address: Address?
    var loadCompletionClosure: Address.RetrieveRequestCallback!

    func loadMainAddressSuccess() {
        loadCompletionClosure(OmiseGO.Response.success(data: self.address!))
    }

    func loadMainAddressFailed(withError error: OmiseGOError) {
        loadCompletionClosure(OmiseGO.Response.fail(error: error))
    }

}

extension MockAddressLoader: AddressLoaderProtocol {

    func getMain(withCallback callback: @escaping Address.RetrieveRequestCallback) {
        self.isLoadAddressCalled = true
        self.loadCompletionClosure = callback
    }

}

class MockSettingLoader {

    var isLoadSettingCalled = false

    var settings: Setting?
    var loadCompletionClosure: Setting.RetrieveRequestCallback!

    func loadSettingSuccess() {
        loadCompletionClosure(OmiseGO.Response.success(data: self.settings!))
    }

    func loadSettingFailed(withError error: OmiseGOError) {
        loadCompletionClosure(OmiseGO.Response.fail(error: error))
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
        generateCompletionClosure(OmiseGO.Response.success(data: self.transactionRequest!))
    }

    func generateTransactionRequestFailed(withError error: OmiseGOError) {
        generateCompletionClosure(OmiseGO.Response.fail(error: error))
    }

}

extension MockTransactionRequestCreator: TransactionRequestCreateProtocol {

    func generate(withParams params: TransactionRequestCreateParams,
                  callback: @escaping TransactionRequest.RetrieveRequestCallback) {
        self.isGenerateCalled = true
        self.generateCompletionClosure = callback
    }

}

class MockTransactionConsumer {

    var isConsumeCalled = false

    var transactionConsume: TransactionConsume?
    var consumeCompletionClosure: TransactionConsume.RetrieveRequestCallback!

    func consumeTransactionSuccess() {
        consumeCompletionClosure(OmiseGO.Response.success(data: self.transactionConsume!))
    }

    func consumeTransactionFailed(withError error: OmiseGOError) {
        consumeCompletionClosure(OmiseGO.Response.fail(error: error))
    }

}

extension MockTransactionConsumer: TransactionConsumeProtocol {

    func consume(withParams params: TransactionConsumeParams,
                 callback: @escaping TransactionConsume.RetrieveRequestCallback) {
        self.isConsumeCalled = true
        self.consumeCompletionClosure = callback
    }

}

extension OMGJSONPaginatedListResponse {

    init(data: [Item], pagination: Pagination) {
        self.data = data
        self.pagination = pagination
    }

}

class MockTransactionLoader {

    var isListCalled = false

    var transactions: [Transaction]?
    var pagination: Pagination?
    var completionClosure: Transaction.ListRequestCallback!

    func loadTransactionSuccess() {
        completionClosure(
            OmiseGO.Response.success(
                data: OMGJSONPaginatedListResponse<Transaction>(data: self.transactions!, pagination: self.pagination!)
            )
        )
    }

    func loadTransactionFailed(withError error: OmiseGOError) {
        completionClosure(OmiseGO.Response.fail(error: error))
    }

}

extension MockTransactionLoader: TransactionLoaderProtocol {

    func list(withParams params: TransactionListParams,
              callback: @escaping Transaction.ListRequestCallback)
        -> Transaction.ListRequest? {
        self.isListCalled = true
        self.completionClosure = callback
        return nil
    }

}
