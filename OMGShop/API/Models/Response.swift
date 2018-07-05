//
//  Response.swift
//  OMGShop
//
//  Created by Mederic Petit on 30/10/17.
//  Copyright © 2017-2018 Omise Go Pte. Ltd. All rights reserved.
//

enum Response<Data> {
    case success(data: Data)
    case fail(error: OMGShopError)
}

struct EmptyResponse: Decodable {}
