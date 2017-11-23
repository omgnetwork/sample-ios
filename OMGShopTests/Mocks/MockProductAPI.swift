//
//  MockProductAPI.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 21/11/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
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
        loadCompletionClosure(.success(data: self.products))
    }

    func loadProductsFailed(withError error: APIError) {
        loadCompletionClosure(.fail(error: OMGError.api(error: error)))
    }

    func paySuccess() {
        payCompletionClosure(.success(data: self.pay!))
    }

    func payFailed(withError error: APIError) {
        payCompletionClosure(.fail(error: OMGError.api(error: error)))
    }

}

extension MockProductAPI: ProductAPIProtocol {

    func getAll(withCompletionClosure completionClosure: @escaping APIClosure<[Product]>) {
        self.isLoadProductsCalled = true
        self.loadCompletionClosure = completionClosure
    }

    func buy(withForm form: BuyForm, completionClosure: @escaping APIClosure<EmptyResponse>) {
        self.isPayCalled = true
        self.payCompletionClosure = completionClosure
    }

}
