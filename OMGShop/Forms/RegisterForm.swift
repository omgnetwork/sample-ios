//
//  RegisterForm.swift
//  OMGShop
//
//  Created by Mederic Petit on 20/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
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
