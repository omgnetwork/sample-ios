//
//  LoginViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 19/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

class LoginViewModel: BaseViewModel {

    // Delegate closures
    var updateEmailValidation: ViewModelValidationClosure?
    var updatePasswordValidation: ViewModelValidationClosure?
    var onSuccessLogin: SuccessClosure?
    var onFailedLogin: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?

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

    var isLoading: Bool = false {
        didSet { self.onLoadStateChange?(isLoading) }
    }

    private let sessionAPI: SessionAPIProtocol
    private let sessionManager: SessionManagerProtocol

    init(sessionAPI: SessionAPIProtocol = SessionAPI(),
         sessionManager: SessionManagerProtocol = SessionManager.shared) {
        self.sessionAPI = sessionAPI
        self.sessionManager = sessionManager
        super.init()
    }

    func login() {
        do {
            try self.validateAll()
            self.isLoading = true
            self.submit()
        } catch let error as OMGError {
            self.onFailedLogin?(error)
        } catch _ {}
    }

    private func submit() {
        let loginForm = LoginForm(email: self.email!, password: self.password!)
        self.sessionAPI.login(withForm: loginForm, completionClosure: { (response) in
            switch response {
            case .success(data: let tokens): self.processLogin(withTokens: tokens)
            case .fail(error: let error):
                self.isLoading = false
                self.onFailedLogin?(error)
            }
        })
    }

    private func processLogin(withTokens tokens: SessionToken) {
        self.sessionManager.login(withAppToken: tokens.authenticationToken,
                                    omiseGOAuthenticationToken: tokens.omiseGOAuthenticationToken,
                                    userId: tokens.userId)
        self.sessionManager.loadCurrentUser(withSuccessClosure: {
            self.isLoading = false
            self.onSuccessLogin?()
        }, failure: { (error) in
            self.isLoading = false
            self.onFailedLogin?(OMGError.omiseGO(error: error))
        })
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
