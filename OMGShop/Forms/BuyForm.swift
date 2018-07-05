//
//  BuyForm.swift
//  OMGShop
//
//  Created by Mederic Petit on 30/10/17.
//  Copyright © 2017-2018 Omise Go Pte. Ltd. All rights reserved.
//

import Foundation

struct BuyForm: Encodable {
    let tokenId: String
    let tokenValue: String
    let productId: String

    private enum CodingKeys: String, CodingKey {
        case tokenId = "token_id"
        case tokenValue = "token_value"
        case productId = "product_id"
    }
}

extension BuyForm: JsonEncodable {
    func encodedBody() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}
