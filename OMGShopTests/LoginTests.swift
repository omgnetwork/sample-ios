//
//  LoginTests.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 24/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import XCTest
@testable import OMGShop

class LoginTests: OMGShopTests {

    func testInvalidEmailAndPassword() {
        var emailError: String?
        var passwordError: String?
        let viewModel: LoginViewModel = LoginViewModel()
        viewModel.updateEmailValidation = { emailError = $0 }
        viewModel.updatePasswordValidation = { passwordError = $0 }
        viewModel.email = "anInvalidEmail"
        viewModel.password = "2shor"
        XCTAssert(emailError == "login.error.validation.email".localized())
        XCTAssert(passwordError == "login.error.validation.password".localized())
    }

    func testValidEmailAndPassword() {
        var emailError: String?
        var passwordError: String?
        let viewModel: LoginViewModel = LoginViewModel()
        viewModel.updateEmailValidation = { emailError = $0 }
        viewModel.updatePasswordValidation = { passwordError = $0 }
        viewModel.email = "email@example.com"
        viewModel.password = "aV@lIdP@ssWord"
        XCTAssert(emailError == nil)
        XCTAssert(passwordError == nil)
    }
}
