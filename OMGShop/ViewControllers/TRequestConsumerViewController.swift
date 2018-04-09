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

    override func configureView() {
        super.configureView()
        self.title = self.viewModel.title

        self.tokenLabel.text = self.viewModel.tokenLabel
        self.amountLabel.text = self.viewModel.amountLabel
        self.addressLabel.text = self.viewModel.addressLabel
        self.correlationIdLabel.text = self.viewModel.correlationIdLabel
        self.expirationDateLabel.text = self.viewModel.expirationDateLabel
        self.consumeButton.setTitle(self.viewModel.consumeButtonTitle, for: .normal)
        self.tableView.tableFooterView = UIView()
        self.setInitialValues()
        self.setupPickers()
        self.setupAccessoryViews()
    }

    private func setInitialValues() {
        self.tokenTextField.text = self.viewModel.mintedTokenDisplay
        self.amountTextField.text = self.viewModel.amountDisplay
        self.addressTextField.text = self.viewModel.addressDisplay
        self.correlationIdTextField.text = self.viewModel.correlationIdDisplay
        self.expirationDateTextField.text = self.viewModel.expirationDateDisplay
    }

    override func configureViewModel() {
        super.configureViewModel()
        self.viewModel.onLoadStateChange = { $0 ? self.showLoading() : self.hideLoading() }
        self.viewModel.onSuccessConsume = {
            self.showMessage($0)
            self.navigationController?.popToRootViewController(animated: true)
        }
        self.viewModel.onSuccessGetSettings = {
            self.tokenTextField.text = self.viewModel.mintedTokenDisplay
        }
        self.viewModel.onFailedConsume = { self.showError(withMessage: $0.localizedDescription) }
        self.viewModel.onFailedGetSettings = { self.showError(withMessage: $0.localizedDescription) }
        self.viewModel.onConsumeButtonStateChange = {
            self.consumeButton.isEnabled = $0
            self.consumeButton.alpha = $0 ? 1 : 0.5
        }
        self.viewModel.onPendingConfirmation = { self.showLoading(withMessage: $0) }
        self.viewModel.loadSettings()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.viewModel.stopListening()
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

    @IBAction func didTapConsumeButton(_ sender: UIButton) {
        self.view.endEditing(true)
        self.viewModel.consumeTransactionRequest()
    }

}

extension TRequestConsumerViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case self.tokenTextField: return self.viewModel.isTokenEnabled
        case self.amountTextField: return self.viewModel.isAmountEnabled
        default: return true
        }
    }

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
        case self.expirationDateTextField: self.viewModel.expirationDateDisplay = ""
        default: break
        }
        return true
    }

}

extension TRequestConsumerViewController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.viewModel.didSelect(row: row)
    }

}

extension TRequestConsumerViewController: UIPickerViewDataSource {

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
