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
        self.viewModel.onFailedGenerate = { self.showError(withMessage: $0.localizedDescription) }
        self.viewModel.onFailedGetSettings = { self.showError(withMessage: $0.localizedDescription) }
        self.viewModel.onGenerateButtonStateChange = {
            self.generateButton.isEnabled = $0
            self.generateButton.alpha = $0 ? 1 : 0.5
        }
        self.viewModel.loadSettings()
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
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        self.tokenTextField.inputView = pickerView
        let datePicker = UIDatePicker()
        datePicker.addTarget(self, action: #selector(didUpdateExpirationDate), for: .valueChanged)
        datePicker.datePickerMode = .dateAndTime
        datePicker.minimumDate = Date()
        self.expirationDateTextField.inputView = datePicker
    }

    func setupAccessoryViews() {
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        accessoryView.backgroundColor = .white
        let nextButton = UIButton(type: .custom)
        nextButton.setTitle(self.viewModel.nextButtonTitle, for: .normal)
        nextButton.titleLabel?.font = Font.avenirMedium.withSize(17)
        nextButton.setTitleColor(.black, for: .normal)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addTarget(self,
                             action: #selector(focusNextTextFieldOrResign),
                             for: .touchUpInside)
        accessoryView.addSubview(nextButton)
        [.top, .trailing, .bottom].forEach {
            accessoryView.addConstraint(NSLayoutConstraint(item: accessoryView,
                                                           attribute: $0,
                                                           relatedBy: .equal,
                                                           toItem: nextButton,
                                                           attribute: $0,
                                                           multiplier: 1,
                                                           constant: 0))
        }
        nextButton.addConstraints([NSLayoutConstraint(item: nextButton,
                                                    attribute: .width,
                                                    relatedBy: .equal,
                                                    toItem: nil,
                                                    attribute: .notAnAttribute,
                                                    multiplier: 1,
                                                    constant: 100),
                                   NSLayoutConstraint(item: nextButton,
                                                      attribute: .height,
                                                      relatedBy: .equal,
                                                      toItem: nil,
                                                      attribute: .notAnAttribute,
                                                      multiplier: 1,
                                                      constant: 44)])
        [self.tokenTextField,
         self.amountTextField,
         self.addressTextField,
         self.correlationIdTextField,
         self.maxConsumptionsTextField,
         self.consumptionLifetimeTextField,
         self.expirationDateTextField].forEach { $0.inputAccessoryView = accessoryView }
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
        self.viewModel.didSelect(row: row)
    }

}

extension TRequestGeneratorViewController: UIPickerViewDataSource {

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.viewModel.title(forRow: row)
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.viewModel.numberOfRowsInPicker()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return self.viewModel.numberOfColumnsInPicker()
    }

}
