//
//  TRequestConsumerViewController.swift
//  OMGShop
//
//  Created by Mederic Petit on 5/4/18.
//  Copyright © 2018 Omise Go Ptd. Ltd. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding

class TRequestConsumerViewController: BaseTableViewController {

    var viewModel: TRequestConsumerViewModel!

    @IBOutlet weak var transactionTypeLabel: UILabel!
    @IBOutlet weak var addressRequesterLabel: UILabel!

    @IBOutlet weak var tokenLabel: UILabel!
    @IBOutlet weak var tokenTextField: UITextField!

    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressTextField: UITextField!

    @IBOutlet weak var correlationIdLabel: UILabel!
    @IBOutlet weak var correlationIdTextField: UITextField!

    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet weak var expirationDateTextField: UITextField!

    @IBOutlet var tpKeyboardAvoidingTableView: TPKeyboardAvoidingTableView!

    @IBOutlet weak var consumeButton: UIButton!

    private var mintedTokenPicker: UIPickerView!
    private var addressPicker: UIPickerView!

    override func configureView() {
        super.configureView()
        self.title = self.viewModel.title

        self.tokenLabel.text = self.viewModel.tokenLabel
        self.amountLabel.text = self.viewModel.amountLabel
        self.addressLabel.text = self.viewModel.addressLabel
        self.correlationIdLabel.text = self.viewModel.correlationIdLabel
        self.consumeButton.setTitle(self.viewModel.consumeButtonTitle, for: .normal)
        self.tokenTextField.isEnabled = self.viewModel.isTokenEnabled
        self.amountTextField.isEnabled = self.viewModel.isAmountEnabled
        self.tableView.tableFooterView = UIView()
        self.setInitialValues()
        self.setupPickers()
        self.setupAccessoryViews()
    }

    private func setInitialValues() {
        self.transactionTypeLabel.text = self.viewModel.transactionTypeDisplay
        self.addressRequesterLabel.text = self.viewModel.requesterAddressDisplay
        self.tokenTextField.text = self.viewModel.mintedTokenDisplay
        self.amountTextField.text = self.viewModel.amountDisplay
        self.addressTextField.text = self.viewModel.addressDisplay
        self.correlationIdTextField.text = self.viewModel.correlationIdDisplay
    }

    override func configureViewModel() {
        super.configureViewModel()
        self.viewModel.onLoadStateChange = { $0 ? self.showLoading() : self.hideLoading() }
        self.viewModel.onSuccessConsume = {
            self.hideLoading()
            self.showMessage($0)
            self.navigationController?.popToRootViewController(animated: true)
        }
        self.viewModel.onSuccessGetSettings = {
            self.tokenTextField.text = self.viewModel.mintedTokenDisplay
        }
        self.viewModel.onSuccessGetAddresses = {
            self.addressTextField.text = self.viewModel.addressDisplay
        }
        self.viewModel.onFailedConsume = {
            self.hideLoading()
            self.showError(withMessage: $0.localizedDescription)
        }
        self.viewModel.onFailedGetSettings = { self.showError(withMessage: $0.localizedDescription) }
        self.viewModel.onFailedLoadAddress = { self.showError(withMessage: $0.localizedDescription) }
        self.viewModel.onConsumeButtonStateChange = {
            self.consumeButton.isEnabled = $0
            self.consumeButton.alpha = $0 ? 1 : 0.5
        }
        self.viewModel.onPendingConfirmation = { self.showLoading(withMessage: $0) }
        self.viewModel.loadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.viewModel.stopListening()
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
    }

    func setupAccessoryViews() {
        [self.tokenTextField,
         self.amountTextField,
         self.addressTextField,
         self.correlationIdTextField,
         self.expirationDateTextField].forEach {
            $0?.addNextInputView(withOnNextSelector: #selector(focusNextTextFieldOrResign), target: self)
        }
    }

    @objc func focusNextTextFieldOrResign() {
        if !self.tpKeyboardAvoidingTableView.focusNextTextField() {
            self.view.endEditing(true)
        }
    }

    @IBAction func didTapConsumeButton(_ sender: UIButton) {
        self.view.endEditing(true)
        self.viewModel.consumeTransactionRequest()
    }

}

extension TRequestConsumerViewController: UITextFieldDelegate {

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
        default: break
        }
        return true
    }

}

extension TRequestConsumerViewController: UIPickerViewDelegate {

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

extension TRequestConsumerViewController: UIPickerViewDataSource {

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
