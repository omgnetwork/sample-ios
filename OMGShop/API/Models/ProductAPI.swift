//
//  ProductAPI.swift
//  OMGShop
//
//  Created by Mederic Petit on 31/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit

class ProductAPI {

    class func getAll(withCompletionClosure completionClosure: @escaping APIClosure<[Product]>) {
        Router.getProducts.request(withCompletionClosure: completionClosure)
    }

    class func buy(withForm form: BuyForm, completionClosure: @escaping APIClosure<EmptyResponse>) {
        Router.buyProduct(withForm: form).request(withCompletionClosure: completionClosure)
    }

}
