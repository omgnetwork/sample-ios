//
//  TRequestGeneratorViewController.swift
//  OMGShop
//
//  Created by Mederic Petit on 3/4/18.
//  Copyright © 2018 Omise Go Ptd. Ltd. All rights reserved.
//

import OmiseGO
import TPKeyboardAvoiding
import UIKit

class TRequestGeneratorViewController: BaseTableViewController {
    let showQRCodeImageSegueIdentifier = "showQRCodeViewer"

    let viewModel = TRequestGeneratorViewModel()

    @IBOutlet var iWantToLabel: UILabel!
    @IBOutlet var sendLabel: UILabel!
    @IBOutlet var receiveLabel: UILabel!
    @IBOutlet var sendReceiveSwitch: UISwitch!

    @IBOutlet var tokenLabel: UILabel!
    @IBOutlet var tokenTextField: UITextField!

    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var amountTextField: UITextField!

    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var addressTextField: UITextField!

    @IBOutlet var correlationIdLabel: UILabel!
    @IBOutlet var correlationIdTextField: UITextField!

    @IBOutlet var requiresConfirmationLabel: UILabel!
    @IBOutlet var requiresConfirmationSwitch: UISwitch!

    @IBOutlet var maxConsumptionLabel: UILabel!
    @IBOutlet var maxConsumptionsTextField: UITextField!

    @IBOutlet var maxConsumptionsPerUserLabel: UILabel!
    @IBOutlet var maxConsumptionsPerUserTextField: UITextField!

    @IBOutlet var consumptionLifetimeLabel: UILabel!
    @IBOutlet var consumptionLifetimeTextField: UITextField!

    @IBOutlet var expirationDateLabel: UILabel!
    @IBOutlet var expirationDateTextField: UITextField!

    @IBOutlet var allowAmountOverrideLabel: UILabel!
    @IBOutlet var allowAmountOverrideSwitch: UISwitch!

    @IBOutlet var tpKeyboardAvoidingTableView: TPKeyboardAvoidingTableView!

    @IBOutlet var generateButton: UIButton!

    private var tokenPicker: UIPickerView!
    private var addressPicker: UIPickerView!

    override func configureView() {
        super.configureView()
        self.title = self.viewModel.title
        self.iWantToLabel.text = self.viewModel.iWantToLabel
        self.sendLabel.text = self.viewModel.sendLabel
        self.receiveLabel.text = self.viewModel.receiveLabel
        self.tokenLabel.text = self.viewModel.tokenLabel
        self.amountLabel.text = self.viewModel.amountLabel
        self.addressLabel.text = self.viewModel.addressLabel
        self.correlationIdLabel.text = self.viewModel.correlationIdLabel
        self.requiresConfirmationLabel.text = self.viewModel.requiresConfirmationLabel
        self.maxConsumptionLabel.text = self.viewModel.maxConsumptionLabel
        self.maxConsumptionsPerUserLabel.text = self.viewModel.maxConsumptionsPerUserLabel
        self.consumptionLifetimeLabel.text = self.viewModel.consumptionLifetimeLabel
        self.expirationDateLabel.text = self.viewModel.expirationDateLabel
        self.allowAmountOverrideLabel.text = self.viewModel.allowAmountOverrideLabel
        self.generateButton.setTitle(self.viewModel.generateButtonTitle, for: .normal)
        self.tableView.tableFooterView = UIView()
        self.setInitialValues()
        self.setupPickers()
        self.setupAccessoryViews()
    }

    private func setInitialValues() {
        self.sendReceiveSwitch.isOn = self.viewModel.sendReceiveSwitchState
        self.tokenTextField.text = self.viewModel.tokenDisplay
        self.amountTextField.text = self.viewModel.amountDisplay
        self.addressTextField.text = self.viewModel.addressDisplay
        self.correlationIdTextField.text = self.viewModel.correlationIdDisplay
        self.requiresConfirmationSwitch.isOn = self.viewModel.requiresConfirmationSwitchState
        self.maxConsumptionsTextField.text = self.viewModel.maxConsumptionsDisplay
        self.maxConsumptionsPerUserTextField.text = self.viewModel.maxConsumptionsPerUserDisplay
        self.consumptionLifetimeTextField.text = self.viewModel.consumptionLifetimeDisplay
        self.expirationDateTextField.text = self.viewModel.expirationDateDisplay
        self.allowAmountOverrideSwitch.isOn = self.viewModel.allowAmountOverrideSwitchState
    }

    override func configureViewModel() {
        super.configureViewModel()
        self.viewModel.onLoadStateChange = { $0 ? self.showLoading() : self.hideLoading() }
        self.viewModel.onSuccessGenerate = { transactionRequest in
            self.performSegue(withIdentifier: self.showQRCodeImageSegueIdentifier, sender: transactionRequest)
        }
        self.viewModel.onSuccessGetSettings = {
            self.tokenTextField.text = self.viewModel.tokenDisplay
        }
        self.viewModel.onSuccessGetWallets = {
            self.addressTextField.text = self.viewModel.addressDisplay
        }
        self.viewModel.onFailedGenerate = { self.showError(withMessage: $0.localizedDescription) }
        self.viewModel.onFailedGetSettings = { self.showError(withMessage: $0.localizedDescription) }
        self.viewModel.onFailedLoadWallet = { self.showError(withMessage: $0.localizedDescription) }
        self.viewModel.onGenerateButtonStateChange = {
            self.generateButton.isEnabled = $0
            self.generateButton.alpha = $0 ? 1 : 0.5
        }
        self.viewModel.onTokenChange = { self.tokenTextField.text = $0 }
        self.viewModel.loadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.showQRCodeImageSegueIdentifier,
            let transactionRequest = sender as? TransactionRequest,
            let vc = segue.destination as? QRCodeViewerViewController {
            let viewModel: QRCodeViewerViewModel = QRCodeViewerViewModel(transactionRequest: transactionRequest)
            vc.viewModel = viewModel
        }
    }

    func setupPickers() {
        self.tokenPicker = UIPickerView()
        self.tokenPicker.dataSource = self
        self.tokenPicker.delegate = self
        self.tokenTextField.inputView = self.tokenPicker
        self.addressPicker = UIPickerView()
        self.addressPicker.dataSource = self
        self.addressPicker.delegate = self
        self.addressTextField.inputView = self.addressPicker
        let datePicker = UIDatePicker()
        datePicker.addTarget(self, action: #selector(self.didUpdateExpirationDate), for: .valueChanged)
        datePicker.datePickerMode = .dateAndTime
        datePicker.minimumDate = Date()
        self.expirationDateTextField.inputView = datePicker
    }

    func setupAccessoryViews() {
        [
            self.tokenTextField,
            self.amountTextField,
            self.addressTextField,
            self.correlationIdTextField,
            self.maxConsumptionsTextField,
            self.consumptionLifetimeTextField,
            self.expirationDateTextField
        ].forEach {
            $0?.addNextInputView(withOnNextSelector: #selector(focusNextTextFieldOrResign), target: self)
        }
    }

    @objc func focusNextTextFieldOrResign() {
        if !self.tpKeyboardAvoidingTableView.focusNextTextField() {
            self.view.endEditing(true)
        }
    }

    @objc func didUpdateExpirationDate(_ picker: UIDatePicker) {
        self.viewModel.didUpdateExpirationDate(picker.date)
        self.expirationDateTextField.text = self.viewModel.expirationDateDisplay
    }

    @IBAction func sendReceiveSwitchDidToggle(_ sender: UISwitch) {
        self.viewModel.sendReceiveSwitchState = sender.isOn
    }

    @IBAction func requiresConfirmationSwitchDidToggle(_ sender: UISwitch) {
        self.viewModel.requiresConfirmationSwitchState = sender.isOn
    }

    @IBAction func allowAmountOverrideSwitchDidToggle(_ sender: UISwitch) {
        self.viewModel.allowAmountOverrideSwitchState = sender.isOn
    }

    @IBAction func didTapGenerateButton(_: UIButton) {
        self.view.endEditing(true)
        self.viewModel.generateTransactionRequest()
    }
}

extension TRequestGeneratorViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_: UITextField) -> Bool {
        self.focusNextTextFieldOrResign()
        return true
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let textAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
        switch textField {
        case self.tokenTextField: self.viewModel.tokenDisplay = textAfterUpdate
        case self.amountTextField: self.viewModel.amountDisplay = textAfterUpdate
        case self.addressTextField: self.viewModel.addressDisplay = textAfterUpdate
        case self.correlationIdTextField: self.viewModel.correlationIdDisplay = textAfterUpdate
        case self.maxConsumptionsTextField: self.viewModel.maxConsumptionsDisplay = textAfterUpdate
        case self.maxConsumptionsPerUserTextField: self.viewModel.maxConsumptionsPerUserDisplay = textAfterUpdate
        case self.consumptionLifetimeTextField: self.viewModel.consumptionLifetimeDisplay = textAfterUpdate
        case self.expirationDateTextField: self.viewModel.expirationDateDisplay = textAfterUpdate
        default: break
        }
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        switch textField {
        case self.tokenTextField: self.viewModel.tokenDisplay = ""
        case self.amountTextField: self.viewModel.amountDisplay = ""
        case self.addressTextField: self.viewModel.addressDisplay = ""
        case self.correlationIdTextField: self.viewModel.correlationIdDisplay = ""
        case self.maxConsumptionsTextField: self.viewModel.maxConsumptionsDisplay = ""
        case self.maxConsumptionsPerUserTextField: self.viewModel.maxConsumptionsPerUserDisplay = ""
        case self.consumptionLifetimeTextField: self.viewModel.consumptionLifetimeDisplay = ""
        case self.expirationDateTextField: self.viewModel.expirationDateDisplay = ""
        default: break
        }
        return true
    }
}

extension TRequestGeneratorViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        switch pickerView {
        case self.tokenPicker: self.viewModel.didSelect(row: row, picker: .token)
        case self.addressPicker: self.viewModel.didSelect(row: row, picker: .address)
        default: break
        }
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent _: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        label.textAlignment = .center
        label.font = Font.avenirBook.withSize(17)
        switch pickerView {
        case self.tokenPicker: label.text = self.viewModel.title(forRow: row, picker: .token)
        case self.addressPicker: label.text = self.viewModel.title(forRow: row, picker: .address)
        default: break
        }
        return label
    }
}

extension TRequestGeneratorViewController: UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        switch pickerView {
        case self.tokenPicker: return self.viewModel.numberOfRows(inPicker: .token)
        case self.addressPicker: return self.viewModel.numberOfRows(inPicker: .address)
        default: return 0
        }
    }

    func numberOfComponents(in _: UIPickerView) -> Int {
        return self.viewModel.numberOfColumnsInPicker()
    }
}
