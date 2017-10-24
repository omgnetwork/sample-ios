//
//  RegisterViewController.swift
//  OMGShop
//
//  Created by Mederic Petit on 19/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding

class RegisterViewController: BaseViewController {

    let viewModel: RegisterViewModel = RegisterViewModel()

    @IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var firstNameTextField: OMGFloatingTextField!
    @IBOutlet weak var lastNameTextField: OMGFloatingTextField!
    @IBOutlet weak var emailTextField: OMGFloatingTextField!
    @IBOutlet weak var passwordTextField: OMGFloatingTextField!
    @IBOutlet weak var registerButton: UIButton!

    override func configureView() {
        super.configureView()
        self.title = self.viewModel.viewTitle
        self.firstNameTextField.placeholder = self.viewModel.firstNamePlaceholder
        self.lastNameTextField.placeholder = self.viewModel.lastNamePlaceholder
        self.emailTextField.placeholder = self.viewModel.emailPlaceholder
        self.passwordTextField.placeholder = self.viewModel.passwordPlaceholder
        self.registerButton.setTitle(self.viewModel.registerButtonTitle, for: .normal)
        self.closeButton.title = self.viewModel.closeButtonTitle.localized()
    }

    override func configureViewModel() {
        super.configureViewModel()
        self.viewModel.updateFirstNameValidation = { self.firstNameTextField.errorMessage = $0 }
        self.viewModel.updateLastNameValidation = { self.lastNameTextField.errorMessage = $0 }
        self.viewModel.updateEmailValidation = { self.emailTextField.errorMessage = $0 }
        self.viewModel.updatePasswordValidation = { self.passwordTextField.errorMessage = $0 }
        self.viewModel.onSuccessRegister = {
            self.hideLoading()
        }
        self.viewModel.onFailedRegister = { (error) in
            self.hideLoading()
            self.showError(withMessage: error.message)
        }
    }

}

extension RegisterViewController {

    @IBAction func tapCloseButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func tapRegisterButton(_ sender: UIButton) {
        self.showLoading()
        self.viewModel.submit()
    }

}

extension RegisterViewController: UITextFieldDelegate {

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
        case firstNameTextField: self.viewModel.firstName = textAfterUpdate
        case lastNameTextField: self.viewModel.lastName = textAfterUpdate
        case emailTextField: self.viewModel.email = textAfterUpdate
        case passwordTextField: self.viewModel.password = textAfterUpdate
        default: break
        }
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        switch textField {
        case firstNameTextField: self.viewModel.firstName = ""
        case lastNameTextField: self.viewModel.lastName = ""
        case emailTextField: self.viewModel.email = ""
        case passwordTextField: self.viewModel.password = ""
        default: break
        }
        return true
    }

}
