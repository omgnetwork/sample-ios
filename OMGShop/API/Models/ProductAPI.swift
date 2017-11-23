//
//  ProductAPI.swift
//  OMGShop
//
//  Created by Mederic Petit on 31/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
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
