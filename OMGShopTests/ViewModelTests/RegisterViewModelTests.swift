//
//  RegisterViewModelTests.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 24/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import XCTest
@testable import OMGShop

class RegisterViewModelTests: XCTestCase {

    var mockSessionAPI: MockSessionAPI!
    var mockSessionManager: MockSessionManager!
    var sut: RegisterViewModel!

    override func setUp() {
        super.setUp()
        self.mockSessionAPI = MockSessionAPI()
        self.mockSessionManager = MockSessionManager()
        self.sut = RegisterViewModel(sessionAPI: self.mockSessionAPI, sessionManager: self.mockSessionManager)
    }

    override func tearDown() {
        self.mockSessionAPI = nil
        self.mockSessionManager = nil
        self.sut = nil
        super.tearDown()
    }

    func testInvalidInput() {
        var firstNameError: String?
        var lastNameError: String?
        var emailError: String?
        var passwordError: String?
        self.sut.updateFirstNameValidation = { firstNameError = $0 }
        self.sut.updateLastNameValidation = { lastNameError = $0 }
        self.sut.updateEmailValidation = { emailError = $0 }
        self.sut.updatePasswordValidation = { passwordError = $0 }
        self.sut.firstName = ""
        self.sut.lastName = ""
        self.sut.email = "anInvalidEmail"
        self.sut.password = "2shor"
        XCTAssert(firstNameError == "register.error.validation.first_name".localized())
        XCTAssert(lastNameError == "register.error.validation.last_name".localized())
        XCTAssert(emailError == "register.error.validation.email".localized())
        XCTAssert(passwordError == "register.error.validation.password".localized())
    }

    func testValidInput() {
        var firstNameError: String?
        var lastNameError: String?
        var emailError: String?
        var passwordError: String?
        self.sut.updateFirstNameValidation = { firstNameError = $0 }
        self.sut.updateLastNameValidation = { lastNameError = $0 }
        self.sut.updateEmailValidation = { emailError = $0 }
        self.sut.updatePasswordValidation = { passwordError = $0 }
        self.fillValidCredentials()
        XCTAssert(firstNameError == nil)
        XCTAssert(lastNameError == nil)
        XCTAssert(emailError == nil)
        XCTAssert(passwordError == nil)
    }

    func testRegisterCalled() {
        self.fillValidCredentials()
        self.sut.register()
        XCTAssert(self.mockSessionAPI.isRegisterCalled)
    }

    func testRegisterFailed() {
        var didFail = false
        self.fillValidCredentials()
        self.sut.onFailedRegister = {
            XCTAssertEqual($0.message, "error")
            didFail = true
        }
        self.sut.register()
        self.mockSessionAPI.loginFailed(withError: .init(code: .other("error"), description: "error"))
        XCTAssert(didFail)
    }

    func testLoginSucceedButLoadCurrentUserFail() {
        self.sut.onFailedRegister = { XCTAssertEqual($0.message, "unexpected error: Failed to load user")}
        self.goToRegisterFinished()
        XCTAssert(self.mockSessionManager.isLoginCalled)
        XCTAssert(self.mockSessionManager.isLoadCurrentUserCalled)
        self.mockSessionManager.loadCurrentUserFailed(withError: .unexpected(message: "Failed to load user"))
    }

    func testLoginAndLoadCurrentUserSucceed() {
        var isLoggedIn = false
        self.sut.onSuccessRegister = { isLoggedIn = true }
        self.goToRegisterFinished()
        XCTAssert(self.mockSessionManager.isLoginCalled)
        XCTAssert(self.mockSessionManager.isLoadCurrentUserCalled)
        self.mockSessionManager.loadCurrentUserSuccess()
        XCTAssert(isLoggedIn)
    }

    func testLoadingWhenRequesting() {
        var loadingStatus = false
        self.sut.onLoadStateChange = { loadingStatus = $0 }
        self.goToRegisterFinished()
        XCTAssertTrue(loadingStatus)
        self.mockSessionManager.loadCurrentUserSuccess()
        XCTAssertFalse(loadingStatus)
    }

    private func fillValidCredentials() {
        self.sut.firstName = "John"
        self.sut.lastName = "Doe"
        self.sut.email = "email@example.com"
        self.sut.password = "aV@lIdP@ssWord"
    }
}

extension RegisterViewModelTests {

    private func goToRegisterFinished() {
        self.fillValidCredentials()
        self.mockSessionAPI.sessionToken = StubGenerator.stubLogin()
        self.sut.register()
        self.mockSessionAPI.registerSuccess()
    }

}
