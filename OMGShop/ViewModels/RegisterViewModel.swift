//
//  RegisterViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 19/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit

class RegisterViewModel: BaseViewModel {

    // Delegate closures
    var updateFirstNameValidation: ViewModelValidationClosure?
    var updateLastNameValidation: ViewModelValidationClosure?
    var updateEmailValidation: ViewModelValidationClosure?
    var updatePasswordValidation: ViewModelValidationClosure?
    var onSuccessRegister: SuccessClosure?
    var onFailedRegister: FailureClosure?

    let viewTitle: String = "register.view.title".localized()
    let firstNamePlaceholder = "register.text_field.placeholder.first_name".localized()
    let lastNamePlaceholder = "register.text_field.placeholder.last_name".localized()
    let emailPlaceholder = "register.text_field.placeholder.email".localized()
    let passwordPlaceholder = "register.text_field.placeholder.password".localized()
    let closeButtonTitle = "register.button.title.close".localized()
    let registerButtonTitle = "register.button.title.register".localized()

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

    func submit() {
        do {
            try self.validateAll()
            let registerForm = RegisterForm(firstName: self.firstName!,
                                            lastName: self.lastName!,
                                            email: self.email!,
                                            password: self.password!)
            // TODO: do the actual operation
            self.onSuccessRegister?()
        } catch let error as OMGError {
            self.onFailedRegister?(error)
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
        self.updateEmailValidation?(isEmailValid ? nil : "register.error.validation.email".localized())
        return isEmailValid
    }

    @discardableResult
    private func validatePassword() -> Bool {
        let isPasswordValid = self.password?.isValidPassword() ?? false
        updatePasswordValidation?(isPasswordValid ? nil : "register.error.validation.password".localized())
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
