//
//  RegisterViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 19/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit

class RegisterViewModel: BaseViewModel {

    var updateFirstNameValidation: ViewModelValidationClosure?
    var updateLastNameValidation: ViewModelValidationClosure?
    var updateEmailValidation: ViewModelValidationClosure?
    var updatePasswordValidation: ViewModelValidationClosure?

    var firstName: String? {
        didSet { self.validateFirstName() }
    }

    var lastName: String? {
        didSet { self.validateLastName() }
    }

    var email: String? {
        didSet { self.validateEmail() }
    }

    var password: String? {
        didSet { self.validatePassword() }
    }

    func submit(withSuccessClosure success: SuccessClosure, failure: FailureClosure) {
        do {
            try self.validateAll()
            let registerForm = RegisterForm(firstName: self.firstName!, lastName: self.lastName!, email: self.email!, password: self.password!)
            // TODO: do the actual operation
            success()
        } catch let error as OMGError {
            failure(error)
        } catch _ {}
    }

    @discardableResult
    private func validateFirstName() -> Bool {
        let isFirstNameValid = self.firstName != nil && !firstName!.isEmpty
        self.updateFirstNameValidation?(isFirstNameValid ? nil : "register.error.validation.first_name".localized())
        return isFirstNameValid
    }

    @discardableResult
    private func validateLastName() -> Bool {
        let isLastNameValid = self.lastName != nil && !lastName!.isEmpty
        self.updateLastNameValidation?(isLastNameValid ? nil : "register.error.validation.last_name".localized())
        return isLastNameValid
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
        var isValid = self.validateFirstName()
        isValid = self.validateLastName() && isValid
        isValid = self.validateEmail() && isValid
        isValid = self.validatePassword() && isValid
        guard isValid else { throw OMGError.missingRequiredFields }
    }

}
