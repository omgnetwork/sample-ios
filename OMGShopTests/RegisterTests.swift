//
//  RegisterTests.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 24/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import XCTest
@testable import OMGShop

class RegisterTests: OMGShopTests {

    func testInvalidInput() {
        var firstNameError: String?
        var lastNameError: String?
        var emailError: String?
        var passwordError: String?
        let viewModel: RegisterViewModel = RegisterViewModel()
        viewModel.updateFirstNameValidation = { firstNameError = $0 }
        viewModel.updateLastNameValidation = { lastNameError = $0 }
        viewModel.updateEmailValidation = { emailError = $0 }
        viewModel.updatePasswordValidation = { passwordError = $0 }
        viewModel.firstName = ""
        viewModel.lastName = ""
        viewModel.email = "anInvalidEmail"
        viewModel.password = "2shor"
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
        let viewModel: RegisterViewModel = RegisterViewModel()
        viewModel.updateFirstNameValidation = { firstNameError = $0 }
        viewModel.updateLastNameValidation = { lastNameError = $0 }
        viewModel.updateEmailValidation = { emailError = $0 }
        viewModel.updatePasswordValidation = { passwordError = $0 }
        viewModel.firstName = "John"
        viewModel.lastName = "Doe"
        viewModel.email = "email@example.com"
        viewModel.password = "aV@lIdP@ssWord"
        XCTAssert(firstNameError == nil)
        XCTAssert(lastNameError == nil)
        XCTAssert(emailError == nil)
        XCTAssert(passwordError == nil)
    }

}
