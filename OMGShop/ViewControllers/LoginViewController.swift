//
//  LoginViewController.swift
//  OMGShop
//
//  Created by Mederic Petit on 19/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding

class LoginViewController: BaseViewController {

    let viewModel: LoginViewModel = LoginViewModel()

    @IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView!
    @IBOutlet weak var emailTextField: OMGFloatingTextField!
    @IBOutlet weak var passwordTextField: OMGFloatingTextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!

    override func configureView() {
        super.configureView()
        self.emailTextField.placeholder = "login.text_field.placeholder.email".localized()
        self.passwordTextField.placeholder = "login.text_field.placeholder.password".localized()
        self.loginButton.setTitle("login.button.title.login".localized(), for: .normal)
        self.registerButton.setTitle("login.button.title.register".localized(), for: .normal)
    }

    override func configureViewModel() {
        super.configureViewModel()
        self.viewModel.updateEmailValidation = { self.emailTextField.errorMessage = $0 }
        self.viewModel.updatePasswordValidation = { self.passwordTextField.errorMessage = $0 }
    }

}

extension LoginViewController {

    @IBAction func tapLoginButton(_ sender: UIButton) {
        self.viewModel.submit(withSuccessClosure: {

        }, failure: { (error) in
            self.showError(withMessage: error.localizedDescription)
        })
    }

}

extension LoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !self.scrollView.tpKeyboardAvoiding_focusNextTextField() {
            textField.resignFirstResponder()
        }
        return true
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let textAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
        switch textField {
        case emailTextField: self.viewModel.email = textAfterUpdate
        case passwordTextField: self.viewModel.password = textAfterUpdate
        default: break
        }
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField: self.viewModel.email = ""
        case passwordTextField: self.viewModel.password = ""
        default: break
        }
        return true
    }

}
