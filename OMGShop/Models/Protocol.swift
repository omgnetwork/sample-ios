//
//  Protocol.swift
//  OMGShop
//
//  Created by Mederic Petit on 30/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import Foundation

protocol JsonEncodable {
    func encodedBody() -> Data?
}
