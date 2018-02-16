//
//  MockOmiseGOWrapper.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 21/11/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
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
