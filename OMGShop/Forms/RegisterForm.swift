//
//  RegisterForm.swift
//  OMGShop
//
//  Created by Mederic Petit on 20/10/17.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

import Foundation

struct RegisterForm: Encodable {
    let firstName: String
    let lastName: String
    let email: String
    let password: String

    private enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case password
    }
}

extension RegisterForm: JsonEncodable {
    func encodedBody() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}
