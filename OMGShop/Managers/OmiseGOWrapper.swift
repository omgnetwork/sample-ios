//
//  OmiseGOWrapper.swift
//  OMGShop
//
//  Created by Mederic Petit on 21/11/17.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

import OmiseGO

protocol WalletLoaderProtocol {
    func getMain(withCallback callback: @escaping Wallet.RetrieveRequestCallback)
    func getAll(withCallback callback: @escaping Wallet.ListRequestCallback)
}

/// This wrapper has been created for the sake of testing with dependency injection
class WalletLoader: WalletLoaderProtocol {

    func getAll(withCallback callback: @escaping Wallet.ListRequestCallback) {
        Wallet.getAll(using: SessionManager.shared.omiseGOClient, callback: callback)
    }

    func getMain(withCallback callback: @escaping Wallet.RetrieveRequestCallback) {
        Wallet.getMain(using: SessionManager.shared.omiseGOClient, callback: callback)
    }

}

protocol SettingLoaderProtocol {
    func get(withCallback callback: @escaping Setting.RetrieveRequestCallback)
}

/// This wrapper has been created for the sake of testing with dependency injection
class SettingLoader: SettingLoaderProtocol {

    func get(withCallback callback: @escaping Setting.RetrieveRequestCallback) {
        Setting.get(using: SessionManager.shared.omiseGOClient, callback: callback)
    }

}

protocol TransactionRequestCreateProtocol {
    func generate(withParams params: TransactionRequestCreateParams,
                  callback: @escaping TransactionRequest.RetrieveRequestCallback)
}

/// This wrapper has been created for the sake of testing with dependency injection
class TransactionRequestLoader: TransactionRequestCreateProtocol {

    func generate(withParams params: TransactionRequestCreateParams,
                  callback: @escaping TransactionRequest.RetrieveRequestCallback) {
        TransactionRequest.create(using: SessionManager.shared.omiseGOClient,
                                  params: params,
                                  callback: callback)
    }

}

protocol TransactionConsumeProtocol {
    func consume(withParams params: TransactionConsumptionParams,
                 callback: @escaping TransactionConsumption.RetrieveRequestCallback)
}

/// This wrapper has been created for the sake of testing with dependency injection
class TransactionConsumeLoader: TransactionConsumeProtocol {

    func consume(withParams params: TransactionConsumptionParams,
                 callback: @escaping TransactionConsumption.RetrieveRequestCallback) {
        TransactionConsumption.consumeTransactionRequest(using: SessionManager.shared.omiseGOClient,
                                                         params: params,
                                                         callback: callback)
    }

}

protocol TransactionLoaderProtocol {

    func list(withParams params: TransactionListParams,
              callback: @escaping Transaction.ListRequestCallback) -> Transaction.ListRequest?

}

/// This wrapper has been created for the sake of testing with dependency injection
class TransactionLoader: TransactionLoaderProtocol {

    @discardableResult
    func list(withParams params: TransactionListParams,
              callback: @escaping Transaction.ListRequestCallback) -> Transaction.ListRequest? {
        return Transaction.list(using: SessionManager.shared.omiseGOClient,
                                params: params,
                                callback: callback)
    }

}
