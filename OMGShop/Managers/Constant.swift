//
//  Constant.swift
//  OMGShop
//
//  Created by Mederic Petit on 25/10/17.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

import UIKit

typealias ViewModelValidationClosure = ((_ errorMessage: String?) -> Void)
typealias EmptyClosure = () -> Void
typealias SuccessClosure = () -> Void
typealias ObjectClosure<T> = (_ object: T) -> Void
typealias FailureClosure = (_ error: OMGShopError) -> Void
typealias APIClosure<T: Decodable> = ObjectClosure<Response<T>>

enum Storyboard {
    case loading
    case login
    case register
    case product
    case popup
    case qrCode

    var name: String {
        switch self {
        case .loading: return "Loading"
        case .login: return "Login"
        case .register: return "Register"
        case .product: return "Product"
        case .popup: return "Popup"
        case .qrCode: return "QRCode"
        }
    }

    var storyboard: UIStoryboard {
        return UIStoryboard.init(name: self.name, bundle: nil)
    }
}

enum UserDefaultKeys: String {
    case userId = "token.user_id"
    case appAuthenticationToken = "token.app_authentication_token"
    case omiseGOAuthenticationToken = "token.omisego_authentication_token"
    case selectedTokenSymbol = "token.selected"
}

enum AppState {
    case logout
    case loading
    case login
}

struct Constant {

    // Config
    static let omiseGOhostURL = "https://ewallet.demo.omisego.io/api/client"
    static let omiseGOSocketURL = "wss://ewallet.demo.omisego.io/api/client/socket"
    static let hostURL = "https://sample-shop.demo.omisego.io/api"
    static let apiKeyId = "1"
    static let apiKey = "f3629628db9316aa3710b2f705db59c1"
    static let omiseGOAPIKey = "zjH7vrLnwxuruQaDIZZ6jqKhlgLTsUCCYusBzUMQ3Ww"
    static let authenticationScheme = "OMGShop"

    // Pagination
    static let perPage = 20

}
