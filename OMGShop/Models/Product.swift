//
//  Product.swift
//  OMGShop
//
//  Created by Mederic Petit on 24/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

struct Product: Decodable {

    let uid: String
    let name: String
    let description: String
    let imageURL: String
    let price: Double
    var displayPrice: String {
        return self.price.displayablePrice()
    }

    private enum CodingKeys: String, CodingKey {
        case uid = "id"
        case name
        case description
        case imageURL = "image_url"
        case price
    }

}
