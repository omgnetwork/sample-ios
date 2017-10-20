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
        self.title = "register.view.title".localized()
        self.firstNameTextField.placeholder = "register.text_field.placeholder.first_name".localized()
        self.lastNameTextField.placeholder = "register.text_field.placeholder.last_name".localized()
        self.emailTextField.placeholder = "register.text_field.placeholder.email".localized()
        self.passwordTextField.placeholder = "register.text_field.placeholder.password".localized()
        self.registerButton.setTitle("register.button.title.register".localized(), for: .normal)
        self.closeButton.title = "register.button.title.close".localized()
    }

    override func configureViewModel() {
        super.configureViewModel()
        self.viewModel.updateFirstNameValidation = { self.firstNameTextField.errorMessage = $0 }
        self.viewModel.updateLastNameValidation = { self.lastNameTextField.errorMessage = $0 }
        self.viewModel.updateEmailValidation = { self.emailTextField.errorMessage = $0 }
        self.viewModel.updatePasswordValidation = { self.passwordTextField.errorMessage = $0 }
    }

}

extension RegisterViewController {

    @IBAction func tapCloseButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func tapRegisterButton(_ sender: UIButton) {
        self.viewModel.submit(withSuccessClosure: {

        }, failure: { (error) in
            self.showError(withMessage: error.localizedDescription)
        })
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
