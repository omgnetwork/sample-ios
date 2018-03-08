//
//  OMGShopManager.swift
//  OMGShop
//
//  Created by Mederic Petit on 20/10/17.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

class OMGShopManager {

    static let shared: OMGShopManager = OMGShopManager()

    init() {
        Theme.apply()
    }

}
