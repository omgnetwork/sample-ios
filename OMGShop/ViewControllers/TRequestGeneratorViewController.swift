//
//  TRequestGeneratorViewController.swift
//  OMGShop
//
//  Created by Mederic Petit on 3/4/18.
//  Copyright © 2018 Omise Go Ptd. Ltd. All rights reserved.
//

import UIKit
import OmiseGO
import TPKeyboardAvoiding

class TRequestGeneratorViewController: BaseTableViewController {

    let showQRCodeImageSegueIdentifier = "showQRCodeViewer"

    let viewModel = TRequestGeneratorViewModel()

    @IBOutlet weak var iWantToLabel: UILabel!
    @IBOutlet weak var sendLabel: UILabel!
    @IBOutlet weak var receiveLabel: UILabel!
    @IBOutlet weak var sendReceiveSwitch: UISwitch!

    @IBOutlet weak var tokenLabel: UILabel!
    @IBOutlet weak var tokenTextField: UITextField!

    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressTextField: UITextField!

    @IBOutlet weak var correlationIdLabel: UILabel!
    @IBOutlet weak var correlationIdTextField: UITextField!

    @IBOutlet weak var requiresConfirmationLabel: UILabel!
    @IBOutlet weak var requiresConfirmationSwitch: UISwitch!

    @IBOutlet weak var maxConsumptionLabel: UILabel!
    @IBOutlet weak var maxConsumptionsTextField: UITextField!

    @IBOutlet weak var consumptionLifetimeLabel: UILabel!
    @IBOutlet weak var consumptionLifetimeTextField: UITextField!

    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet weak var expirationDateTextField: UITextField!

    @IBOutlet weak var allowAmountOverrideLabel: UILabel!
    @IBOutlet weak var allowAmountOverrideSwitch: UISwitch!

    @IBOutlet var tpKeyboardAvoidingTableView: TPKeyboardAvoidingTableView!

    @IBOutlet weak var generateButton: UIButton!

    private var mintedTokenPicker: UIPickerView!
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
        self.tokenTextField.text = self.viewModel.mintedTokenDisplay
        self.amountTextField.text = self.viewModel.amountDisplay
        self.addressTextField.text = self.viewModel.addressDisplay
        self.correlationIdTextField.text = self.viewModel.correlationIdDisplay
        self.requiresConfirmationSwitch.isOn = self.viewModel.requiresConfirmationSwitchState
        self.maxConsumptionsTextField.text = self.viewModel.maxConsumptionsDisplay
        self.consumptionLifetimeTextField.text = self.viewModel.consumptionLifetimeDisplay
        self.expirationDateTextField.text = self.viewModel.expirationDateDisplay
        self.allowAmountOverrideSwitch.isOn = self.viewModel.allowAmountOverrideSwitchState
    }

    override func configureViewModel() {
        super.configureViewModel()
        self.viewModel.onLoadStateChange = { $0 ? self.showLoading() : self.hideLoading() }
        self.viewModel.onSuccessGenerate = { (transactionRequest) in
            self.performSegue(withIdentifier: self.showQRCodeImageSegueIdentifier, sender: transactionRequest)
        }
        self.viewModel.onSuccessGetSettings = {
            self.tokenTextField.text = self.viewModel.mintedTokenDisplay
        }
        self.viewModel.onSuccessGetAddresses = {
            self.addressTextField.text = self.viewModel.addressDisplay
        }
        self.viewModel.onFailedGenerate = { self.showError(withMessage: $0.localizedDescription) }
        self.viewModel.onFailedGetSettings = { self.showError(withMessage: $0.localizedDescription) }
        self.viewModel.onFailedLoadAddress = { self.showError(withMessage: $0.localizedDescription) }
        self.viewModel.onGenerateButtonStateChange = {
            self.generateButton.isEnabled = $0
            self.generateButton.alpha = $0 ? 1 : 0.5
        }
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
        self.mintedTokenPicker = UIPickerView()
        self.mintedTokenPicker.dataSource = self
        self.mintedTokenPicker.delegate = self
        self.tokenTextField.inputView = self.mintedTokenPicker
        self.addressPicker = UIPickerView()
        self.addressPicker.dataSource = self
        self.addressPicker.delegate = self
        self.addressTextField.inputView = self.addressPicker
        let datePicker = UIDatePicker()
        datePicker.addTarget(self, action: #selector(didUpdateExpirationDate), for: .valueChanged)
        datePicker.datePickerMode = .dateAndTime
        datePicker.minimumDate = Date()
        self.expirationDateTextField.inputView = datePicker
    }

    func setupAccessoryViews() {
        [self.tokenTextField,
         self.amountTextField,
         self.addressTextField,
         self.correlationIdTextField,
         self.maxConsumptionsTextField,
         self.consumptionLifetimeTextField,
         self.expirationDateTextField].forEach {
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

    @IBAction func didTapGenerateButton(_ sender: UIButton) {
        self.view.endEditing(true)
        self.viewModel.generateTransactionRequest()
    }

}

extension TRequestGeneratorViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.focusNextTextFieldOrResign()
        return true
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let textAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
        switch textField {
        case self.tokenTextField: self.viewModel.mintedTokenDisplay = textAfterUpdate
        case self.amountTextField: self.viewModel.amountDisplay = textAfterUpdate
        case self.addressTextField: self.viewModel.addressDisplay = textAfterUpdate
        case self.correlationIdTextField: self.viewModel.correlationIdDisplay = textAfterUpdate
        case self.maxConsumptionsTextField: self.viewModel.maxConsumptionsDisplay = textAfterUpdate
        case self.consumptionLifetimeTextField: self.viewModel.consumptionLifetimeDisplay = textAfterUpdate
        case self.expirationDateTextField: self.viewModel.expirationDateDisplay = textAfterUpdate
        default: break
        }
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        switch textField {
        case self.tokenTextField: self.viewModel.mintedTokenDisplay = ""
        case self.amountTextField: self.viewModel.amountDisplay = ""
        case self.addressTextField: self.viewModel.addressDisplay = ""
        case self.correlationIdTextField: self.viewModel.correlationIdDisplay = ""
        case self.maxConsumptionsTextField: self.viewModel.maxConsumptionsDisplay = ""
        case self.consumptionLifetimeTextField: self.viewModel.consumptionLifetimeDisplay = ""
        case self.expirationDateTextField: self.viewModel.expirationDateDisplay = ""
        default: break
        }
        return true
    }

}

extension TRequestGeneratorViewController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case self.mintedTokenPicker: self.viewModel.didSelect(row: row, picker: .mintedToken)
        case self.addressPicker: self.viewModel.didSelect(row: row, picker: .address)
        default: break
        }
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        label.textAlignment = .center
        label.font = Font.avenirBook.withSize(17)
        switch pickerView {
        case self.mintedTokenPicker: label.text = self.viewModel.title(forRow: row, picker: .mintedToken)
        case self.addressPicker: label.text = self.viewModel.title(forRow: row, picker: .address)
        default: break
        }
        return label
    }

}

extension TRequestGeneratorViewController: UIPickerViewDataSource {

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case self.mintedTokenPicker: return self.viewModel.numberOfRows(inPicker: .mintedToken)
        case self.addressPicker: return self.viewModel.numberOfRows(inPicker: .address)
        default: return 0
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return self.viewModel.numberOfColumnsInPicker()
    }

}
