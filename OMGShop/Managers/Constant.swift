//
//  Constant.swift
//  OMGShop
//
//  Created by Mederic Petit on 25/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit

typealias ViewModelValidationClosure = ((_ errorMessage: String?) -> Void)
typealias EmptyClosure = () -> Void
typealias SuccessClosure = () -> Void
typealias ObjectClosure<T> = (_ object: T) -> Void
typealias FailureClosure = (_ error: OMGError) -> Void

enum Storyboard {
    case login
    case register
    case product
    case popup

    var name: String {
        switch self {
        case .login: return "Login"
        case .register: return "Register"
        case .product: return "Product"
        case .popup: return "Popup"
        }
    }

    var storyboard: UIStoryboard {
        return UIStoryboard.init(name: self.name, bundle: nil)
    }
}
