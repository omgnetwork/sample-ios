//
//  SessionToken.swift
//  OMGShop
//
//  Created by Mederic Petit on 30/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit

struct SessionToken: Decodable {

    let userId: String
    let authenticationToken: String
    let omiseGOAuthenticationToken: String

    private enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case authenticationToken = "authentication_token"
        case omiseGOAuthenticationToken = "omisego_authentication_token"
    }

}
