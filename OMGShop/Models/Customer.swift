//
//  Customer.swift
//  OMGShop
//
//  Created by Mederic Petit on 30/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit

struct Customer: Decodable {

    let email: String
    let firstName: String
    let lastName: String

    static func dummy() -> Customer {
        return Customer(email: "test@example.com", firstName: "John", lastName: "Doe")
    }

    private enum CodingKeys: String, CodingKey {
        case email
        case firstName = "first_name"
        case lastName = "last_name"
    }

}
