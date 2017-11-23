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
