//
//  TRequestGeneratorViewController.swift
//  OMGShop
//
//  Created by Mederic Petit on 3/4/18.
//  Copyright © 2018 Omise Go Ptd. Ltd. All rights reserved.
//

import UIKit

class TRequestGeneratorViewController: BaseTableViewController {

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

    lazy var generateButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(self.viewModel.generateButtonTitle, for: .normal)
        button.backgroundColor = Color.omiseGOBlue.uiColor()
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

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
        self.setInitialValues()
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
        self.viewModel.onLoadStateChange = { $0 ? self.showLoading() : self.hideLoading()}
        self.viewModel.onSuccessGenerate = { (transactionRequest) in
            // TODO: Handle success
        }
        self.viewModel.onFailedGenerate = { self.showError(withMessage: $0.localizedDescription) }
        self.viewModel.onFailedGetSettings = { self.showError(withMessage: $0.localizedDescription) }
        self.viewModel.onGenerateButtonStateChange = {
            self.generateButton.isEnabled = $0
            self.generateButton.alpha = $0 ? 1 : 0.5
        }
        self.viewModel.loadSettings()
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

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 76
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .white
        footerView.addSubview(self.generateButton)
        [.trailing, .bottom].forEach {
            footerView.addConstraint(NSLayoutConstraint(item: footerView,
                                                        attribute: $0,
                                                        relatedBy: .equal,
                                                        toItem: self.generateButton,
                                                        attribute: $0,
                                                        multiplier: 1,
                                                        constant: 16))
        }
        [.leading, .top].forEach {
            footerView.addConstraint(NSLayoutConstraint(item: footerView,
                                                        attribute: $0,
                                                        relatedBy: .equal,
                                                        toItem: self.generateButton,
                                                        attribute: $0,
                                                        multiplier: 1,
                                                        constant: -16))
        }
        return footerView
    }

}

extension TRequestGeneratorViewController: UITextFieldDelegate {


//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }

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
