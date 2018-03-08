//
//  Product.swift
//  OMGShop
//
//  Created by Mederic Petit on 24/10/17.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

struct Product: Decodable {

    let uid: String
    let name: String
    let description: String
    let imageURL: String
    let price: Double

    private enum CodingKeys: String, CodingKey {
        case uid = "id"
        case name
        case description
        case imageURL = "image_url"
        case price
    }

}
