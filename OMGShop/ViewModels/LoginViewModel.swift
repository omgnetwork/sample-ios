//
//  LoginViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 19/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit

class LoginViewModel: BaseViewModel {

    // Delegate closures
    var updateEmailValidation: ViewModelValidationClosure?
    var updatePasswordValidation: ViewModelValidationClosure?
    var onSuccessLogin: SuccessClosure?
    var onFailedLogin: FailureClosure?

    let emailPlaceholder = "login.text_field.placeholder.email".localized()
    let passwordPlaceholder = "login.text_field.placeholder.password".localized()
    let loginButtonTitle = "login.button.title.login".localized()
    let registerButtonTitle = "login.button.title.register".localized()

    var email: String? {
        didSet { self.validateEmail() }
    }

    var password: String? {
        didSet { self.validatePassword() }
    }

    func submit() {
        do {
            try self.validateAll()
            let loginForm = LoginForm(email: self.email!, password: self.password!)
            // TODO: do the actual operation
            self.onSuccessLogin?()
        } catch let error as OMGError {
            self.onFailedLogin?(error)
        } catch _ {}
    }

    @discardableResult
    private func validateEmail() -> Bool {
        let isEmailValid = self.email?.isValidEmailAddress() ?? false
        self.updateEmailValidation?(isEmailValid ? nil : "login.error.validation.email".localized())
        return isEmailValid
    }

    @discardableResult
    private func validatePassword() -> Bool {
        let isPasswordValid = self.password?.isValidPassword() ?? false
        updatePasswordValidation?(isPasswordValid ? nil : "login.error.validation.password".localized())
        return isPasswordValid
    }

    private func validateAll() throws {
        // We use this syntax to force to go over all validation and don't stop when something is invalid
        // So we can show to the user all fields that have errors
        var isValid = self.validateEmail()
        isValid = self.validatePassword() && isValid
        guard isValid else { throw OMGError.missingRequiredFields }
    }

}
