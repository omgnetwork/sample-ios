//
//  SessionAPI.swift
//  OMGShop
//
//  Created by Mederic Petit on 30/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit

class SessionAPI {

    class func login(withForm form: LoginForm, completionClosure:@escaping APIClosure<SessionToken>) {
        completionClosure(.success(data: SessionToken(authenticationToken: "qwe", omiseGOAuthenticationToken: "qwe")))
        //TODO: Uncomment this
//        Router.login(withForm: form).request(withCompletionClosure: completionClosure)
    }

    class func register(withForm form: RegisterForm, completionClosure:@escaping APIClosure<SessionToken>) {
        completionClosure(.success(data: SessionToken(authenticationToken: "qwe", omiseGOAuthenticationToken: "qwe")))
        //TODO: Uncomment this
//        Router.register(withForm: form).request(withCompletionClosure: completionClosure)
    }

}
