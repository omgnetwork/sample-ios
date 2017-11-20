//
//  BuyForm.swift
//  OMGShop
//
//  Created by Mederic Petit on 30/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit

struct BuyForm: Encodable {

    let tokenId: String
    let tokenValue: Double
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
