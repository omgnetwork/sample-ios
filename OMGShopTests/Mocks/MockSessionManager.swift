//
//  MockSessionManager.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 21/11/17.
//  Copyright © 2017-2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import OMGShop
import OmiseGO

class MockSessionManager: SessionManagerProtocol {
    var currentUser: User?

    var isLoginCalled = false
    var isLoadCurrentUserCalled = false
    var isLogoutCalled = false

    var successClosure: SuccessClosure!
    var failureLoadUserClosure: ((OMGError) -> Void)!
    var failureLogoutClosure: FailureClosure!

    func loadCurrentUserSuccess() {
        self.successClosure()
    }

    func loadCurrentUserFailed(withError error: OMGError) {
        self.failureLoadUserClosure(error)
    }

    func logoutSuccess() {
        self.successClosure()
    }

    func logoutFailed(withError error: OMGShop.APIError) {
        self.failureLogoutClosure(.api(error: error))
    }

    func login(withAppToken _: String, omiseGOAuthenticationToken _: String, userId _: String) {
        self.isLoginCalled = true
    }

    func loadCurrentUser(withSuccessClosure success: @escaping SuccessClosure,
                         failure: @escaping (OMGError) -> Void) {
        self.isLoadCurrentUserCalled = true
        self.successClosure = success
        self.failureLoadUserClosure = failure
    }

    func logout(withSuccessClosure success: @escaping SuccessClosure,
                failure: @escaping FailureClosure) {
        self.isLogoutCalled = true
        self.successClosure = success
        self.failureLogoutClosure = failure
    }
}
