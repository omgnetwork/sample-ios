//
//  LoginViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 19/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit

class LoginViewModel: BaseViewModel {

    var updateEmailValidation: ViewModelValidationClosure?
    var updatePasswordValidation: ViewModelValidationClosure?

    var email: String? {
        didSet { self.validateEmail() }
    }

    var password: String? {
        didSet { self.validatePassword() }
    }

    func submit(withSuccessClosure success: SuccessClosure, failure: FailureClosure) {
        do {
            try self.validateAll()
            // TODO: do the actual operation
            success()
        } catch let error as OMGError {
            failure(error)
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
