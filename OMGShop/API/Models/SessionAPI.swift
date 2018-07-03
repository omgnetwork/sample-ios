//
//  SessionAPI.swift
//  OMGShop
//
//  Created by Mederic Petit on 30/10/17.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

protocol SessionAPIProtocol {
    func login(withForm form: LoginForm, completionClosure: @escaping APIClosure<SessionToken>)
    func register(withForm form: RegisterForm, completionClosure: @escaping APIClosure<SessionToken>)
}

class SessionAPI: SessionAPIProtocol {
    func login(withForm form: LoginForm, completionClosure: @escaping APIClosure<SessionToken>) {
        Router.login(withForm: form).request(withCompletionClosure: completionClosure)
    }

    func register(withForm form: RegisterForm, completionClosure: @escaping APIClosure<SessionToken>) {
        Router.register(withForm: form).request(withCompletionClosure: completionClosure)
    }
}
