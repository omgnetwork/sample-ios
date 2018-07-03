//
//  MockSessionAPI.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 21/11/17.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

@testable import OMGShop

class MockSessionAPI {
    var isLoginCalled = false
    var isRegisterCalled = false

    var sessionToken: SessionToken?
    var completionClosure: APIClosure<SessionToken>!

    func loginSuccess() {
        self.completionClosure(.success(data: self.sessionToken!))
    }

    func loginFailed(withError error: APIError) {
        self.completionClosure(.fail(error: OMGShopError.api(error: error)))
    }

    func registerSuccess() {
        self.completionClosure(.success(data: self.sessionToken!))
    }

    func registerFailed(withError error: APIError) {
        self.completionClosure(.fail(error: OMGShopError.api(error: error)))
    }
}

extension MockSessionAPI: SessionAPIProtocol {
    func login(withForm _: LoginForm, completionClosure: @escaping APIClosure<SessionToken>) {
        self.isLoginCalled = true
        self.completionClosure = completionClosure
    }

    func register(withForm _: RegisterForm, completionClosure: @escaping APIClosure<SessionToken>) {
        self.isRegisterCalled = true
        self.completionClosure = completionClosure
    }
}
