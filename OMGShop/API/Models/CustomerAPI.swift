//
//  CustomerAPI.swift
//  OMGShop
//
//  Created by Mederic Petit on 31/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit

class CustomerAPI {

    class func getCurrent(withCompletionClosure completionClosure: @escaping APIClosure<Customer>) {
        completionClosure(.success(data: Customer.dummy()))
        //TODO: Uncomment this
//        Router.getCurrentUser.request(withCompletionClosure: completionClosure)
    }

}
