//
//  MockSessionManager.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 21/11/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

@testable import OMGShop
import OmiseGO

class MockSessionManager: SessionManagerProtocol {

    var currentUser: User?

    var isLoginCalled = false
    var isLoadCurrentUserCalled = false
    var isLogoutCalled = false

    var successClosure: SuccessClosure!
    var failureLoadUserClosure: ((OmiseGOError) -> Void)!
    var failureLogoutClosure: FailureClosure!

    func loadCurrentUserSuccess() {
        self.successClosure()
    }

    func loadCurrentUserFailed(withError error: OmiseGOError) {
        self.failureLoadUserClosure(error)
    }

    func logoutSuccess() {
        self.successClosure()
    }

    func logoutFailed(withError error: OMGShop.APIError) {
        self.failureLogoutClosure(.api(error: error))
    }

    func login(withAppToken appAuthenticationToken: String, omiseGOAuthenticationToken: String, userId: String) {
        self.isLoginCalled = true
    }

    func loadCurrentUser(withSuccessClosure success: @escaping SuccessClosure,
                         failure: @escaping (OmiseGOError) -> Void) {
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
