//
//  SessionToken.swift
//  OMGShop
//
//  Created by Mederic Petit on 30/10/17.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

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
