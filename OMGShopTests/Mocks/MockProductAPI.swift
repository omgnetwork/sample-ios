//
//  MockProductAPI.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 21/11/17.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

@testable import OMGShop

class MockProductAPI {
    var isLoadProductsCalled = false
    var isPayCalled = false

    var products: [Product] = []
    var pay: EmptyResponse?
    var loadCompletionClosure: APIClosure<[Product]>!
    var payCompletionClosure: APIClosure<EmptyResponse>!

    func loadProductsSuccess() {
        self.loadCompletionClosure(.success(data: self.products))
    }

    func loadProductsFailed(withError error: APIError) {
        self.loadCompletionClosure(.fail(error: OMGShopError.api(error: error)))
    }

    func paySuccess() {
        self.payCompletionClosure(.success(data: self.pay!))
    }

    func payFailed(withError error: APIError) {
        self.payCompletionClosure(.fail(error: OMGShopError.api(error: error)))
    }
}

extension MockProductAPI: ProductAPIProtocol {
    func getAll(withCompletionClosure completionClosure: @escaping APIClosure<[Product]>) {
        self.isLoadProductsCalled = true
        self.loadCompletionClosure = completionClosure
    }

    func buy(withForm _: BuyForm, completionClosure: @escaping APIClosure<EmptyResponse>) {
        self.isPayCalled = true
        self.payCompletionClosure = completionClosure
    }
}
