//
//  Product.swift
//  OMGShop
//
//  Created by Mederic Petit on 24/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit

struct Product: Decodable {

    let uid: String
    let name: String
    let description: String
    let imageURL: String
    let price: Double
    var displayPrice: String {
        return self.price.displayablePrice()
    }

    static func dummies() -> [Product] {
        let p1 = Product(uid: "1",
                         name: "OmiseGO T-shirt 1",
                         description: "This is an awesome T-shirt",
                         imageURL: "https://image.ibb.co/cyfcfm/tshirt_sample_3x.png",
                         price: 98500)
        let p2 = Product(uid: "2",
                         name: "OmiseGO T-shirt 2",
                         description: "This is an other awesome T-shirt",
                         imageURL: "https://image.ibb.co/cyfcfm/tshirt_sample_3x.png",
                         price: 15500)
        let p3 = Product(uid: "3",
                         name: "OmiseGO T-shirt 3",
                         description: "This is an other awesome T-shirt",
                         imageURL: "https://image.ibb.co/cyfcfm/tshirt_sample_3x.png",
                         price: 45000)
        return [p1, p2, p3]
    }

    private enum CodingKeys: String, CodingKey {
        case uid = "id"
        case name
        case description
        case imageURL = "image_url"
        case price
    }

}
