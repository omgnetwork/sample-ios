//
//  Response.swift
//  OMGShop
//
//  Created by Mederic Petit on 30/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

enum Response<Data> {
    case success(data: Data)
    case fail(error: OMGError)
}

struct EmptyResponse: Decodable {}
