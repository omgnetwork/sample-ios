//
//  ProductAPI.swift
//  OMGShop
//
//  Created by Mederic Petit on 31/10/17.
//  Copyright © 2017-2018 Omise Go Pte. Ltd. All rights reserved.
//

protocol ProductAPIProtocol {
    func getAll(withCompletionClosure completionClosure: @escaping APIClosure<[Product]>)
    func buy(withForm form: BuyForm, completionClosure: @escaping APIClosure<EmptyResponse>)
}

class ProductAPI: ProductAPIProtocol {
    func getAll(withCompletionClosure completionClosure: @escaping APIClosure<[Product]>) {
        Router.getProducts.request(withCompletionClosure: completionClosure)
    }

    func buy(withForm form: BuyForm, completionClosure: @escaping APIClosure<EmptyResponse>) {
        Router.buyProduct(withForm: form).request(withCompletionClosure: completionClosure)
    }
}
