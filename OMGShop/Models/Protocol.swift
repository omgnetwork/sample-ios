//
//  Protocol.swift
//  OMGShop
//
//  Created by Mederic Petit on 30/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit
import Alamofire

protocol JsonEncodable {
    func encodedBody() -> Data?
}
