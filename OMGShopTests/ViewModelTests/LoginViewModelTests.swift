//
//  LoginViewModelTests.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 24/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import XCTest
@testable import OMGShop

class LoginViewModelTests: XCTestCase {

    var mockSessionAPI: MockSessionAPI!
    var mockSessionManager: MockSessionManager!
    var sut: LoginViewModel!

    override func setUp() {
        super.setUp()
        self.mockSessionAPI = MockSessionAPI()
        self.mockSessionManager = MockSessionManager()
        self.sut = LoginViewModel(sessionAPI: self.mockSessionAPI, sessionManager: self.mockSessionManager)
    }

    override func tearDown() {
        self.mockSessionAPI = nil
        self.mockSessionManager = nil
        self.sut = nil
        super.tearDown()
    }

    func testInvalidEmailAndPassword() {
        var emailError: String?
        var passwordError: String?
        self.sut.updateEmailValidation = { emailError = $0 }
        self.sut.updatePasswordValidation = { passwordError = $0 }
        self.sut.email = "anInvalidEmail"
        self.sut.password = "2shor"
        XCTAssert(emailError == "login.error.validation.email".localized())
        XCTAssert(passwordError == "login.error.validation.password".localized())
    }

    func testValidEmailAndPassword() {
        var emailError: String?
        var passwordError: String?
        self.sut.updateEmailValidation = { emailError = $0 }
        self.sut.updatePasswordValidation = { passwordError = $0 }
        self.fillValidCredentials()
        XCTAssert(emailError == nil)
        XCTAssert(passwordError == nil)
    }

    func testLoginCalled() {
        self.fillValidCredentials()
        self.sut.login()
        XCTAssert(self.mockSessionAPI.isLoginCalled)
    }

    func testLoginFailed() {
        var didFail = false
        self.fillValidCredentials()
        self.sut.onFailedLogin = {
            XCTAssertEqual($0.message, "error")
            didFail = true
        }
        self.sut.login()
        self.mockSessionAPI.loginFailed(withError: .init(code: .other("error"), description: "error"))
        XCTAssert(didFail)
    }

    func testLoginSucceedButLoadCurrentUserFail() {
        self.sut.onFailedLogin = { XCTAssertEqual($0.message, "unexpected error: Failed to load user")}
        self.goToLoginFinished()
        XCTAssert(self.mockSessionManager.isLoginCalled)
        XCTAssert(self.mockSessionManager.isLoadCurrentUserCalled)
        self.mockSessionManager.loadCurrentUserFailed(withError: .unexpected(message: "Failed to load user"))
    }

    func testLoginAndLoadCurrentUserSucceed() {
        var isLoggedIn = false
        self.sut.onSuccessLogin = { isLoggedIn = true }
        self.goToLoginFinished()
        XCTAssert(self.mockSessionManager.isLoginCalled)
        XCTAssert(self.mockSessionManager.isLoadCurrentUserCalled)
        self.mockSessionManager.loadCurrentUserSuccess()
        XCTAssert(isLoggedIn)
    }

    func testLoadingWhenRequesting() {
        var loadingStatus = false
        self.sut.onLoadStateChange = { loadingStatus = $0 }
        self.goToLoginFinished()
        XCTAssertTrue(loadingStatus)
        self.mockSessionManager.loadCurrentUserSuccess()
        XCTAssertFalse(loadingStatus)
    }

    private func fillValidCredentials() {
        self.sut.email = "email@example.com"
        self.sut.password = "aV@lIdP@ssWord"
    }
}

extension LoginViewModelTests {

    private func goToLoginFinished() {
        self.fillValidCredentials()
        self.mockSessionAPI.sessionToken = StubGenerator.stubLogin()
        self.sut.login()
        self.mockSessionAPI.loginSuccess()
    }

}
