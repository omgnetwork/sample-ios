//
//  LoginForm.swift
//  OMGShop
//
//  Created by Mederic Petit on 20/10/17.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

import Foundation

struct LoginForm: Encodable {

    let email: String
    let password: String

}

extension LoginForm: JsonEncodable {

    func encodedBody() -> Data? {
        return try? JSONEncoder().encode(self)
    }

}
