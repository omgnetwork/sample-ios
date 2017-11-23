//
//  LoginForm.swift
//  OMGShop
//
//  Created by Mederic Petit on 20/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
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
