//
//  RegisterViewController.swift
//  OMGShop
//
//  Created by Mederic Petit on 19/10/17.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

import TPKeyboardAvoiding

class RegisterViewController: BaseViewController {
    let viewModel: RegisterViewModel = RegisterViewModel()

    @IBOutlet var scrollView: TPKeyboardAvoidingScrollView!
    @IBOutlet var closeButton: UIBarButtonItem!
    @IBOutlet var firstNameTextField: OMGFloatingTextField!
    @IBOutlet var lastNameTextField: OMGFloatingTextField!
    @IBOutlet var emailTextField: OMGFloatingTextField!
    @IBOutlet var passwordTextField: OMGFloatingTextField!
    @IBOutlet var registerButton: UIButton!

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
        self.viewModel.onLoadStateChange = { $0 ? self.showLoading() : self.hideLoading() }
        self.viewModel.onSuccessRegister = {
            self.dismiss(animated: false, completion: {
                (UIApplication.shared.delegate as? AppDelegate)?.loadRootView()
            })
        }
        self.viewModel.onFailedRegister = { self.showError(withMessage: $0.localizedDescription) }
    }
}

extension RegisterViewController {
    @IBAction func tapCloseButton(_: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func tapRegisterButton(_: UIButton) {
        self.view.endEditing(true)
        self.viewModel.register()
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !self.scrollView.tpKeyboardAvoiding_focusNextTextField() {
            textField.resignFirstResponder()
            self.viewModel.register()
        }
        return true
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let textAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
        switch textField {
        case self.firstNameTextField: self.viewModel.firstName = textAfterUpdate
        case self.lastNameTextField: self.viewModel.lastName = textAfterUpdate
        case self.emailTextField: self.viewModel.email = textAfterUpdate
        case self.passwordTextField: self.viewModel.password = textAfterUpdate
        default: break
        }
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        switch textField {
        case self.firstNameTextField: self.viewModel.firstName = ""
        case self.lastNameTextField: self.viewModel.lastName = ""
        case self.emailTextField: self.viewModel.email = ""
        case self.passwordTextField: self.viewModel.password = ""
        default: break
        }
        return true
    }
}
