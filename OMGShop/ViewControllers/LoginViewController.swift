//
//  LoginViewController.swift
//  OMGShop
//
//  Created by Mederic Petit on 19/10/17.
//  Copyright © 2017-2018 Omise Go Pte. Ltd. All rights reserved.
//

import TPKeyboardAvoiding

class LoginViewController: BaseViewController {
    let viewModel: LoginViewModel = LoginViewModel()

    @IBOutlet var scrollView: TPKeyboardAvoidingScrollView!
    @IBOutlet var emailTextField: OMGFloatingTextField!
    @IBOutlet var passwordTextField: OMGFloatingTextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var registerButton: UIButton!

    override func configureView() {
        super.configureView()
        self.emailTextField.placeholder = self.viewModel.emailPlaceholder
        self.passwordTextField.placeholder = self.viewModel.passwordPlaceholder
        self.loginButton.setTitle(self.viewModel.loginButtonTitle, for: .normal)
        self.registerButton.setTitle(self.viewModel.registerButtonTitle, for: .normal)
    }

    override func configureViewModel() {
        super.configureViewModel()
        self.viewModel.updateEmailValidation = { self.emailTextField.errorMessage = $0 }
        self.viewModel.updatePasswordValidation = { self.passwordTextField.errorMessage = $0 }
        self.viewModel.onLoadStateChange = { $0 ? self.showLoading() : self.hideLoading() }
        self.viewModel.onSuccessLogin = { (UIApplication.shared.delegate as? AppDelegate)?.loadRootView() }
        self.viewModel.onFailedLogin = { self.showError(withMessage: $0.localizedDescription) }
    }
}

extension LoginViewController {
    @IBAction func tapLoginButton(_: UIButton) {
        self.view.endEditing(true)
        self.viewModel.login()
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !self.scrollView.tpKeyboardAvoiding_focusNextTextField() {
            textField.resignFirstResponder()
            self.viewModel.login()
        }
        return true
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let textAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
        switch textField {
        case self.emailTextField: self.viewModel.email = textAfterUpdate
        case self.passwordTextField: self.viewModel.password = textAfterUpdate
        default: break
        }
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        switch textField {
        case self.emailTextField: self.viewModel.email = ""
        case self.passwordTextField: self.viewModel.password = ""
        default: break
        }
        return true
    }
}
