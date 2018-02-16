//
//  QRCodeGeneratorViewController.swift
//  OMGShop
//
//  Created by Mederic Petit on 13/2/2561 BE.
//  Copyright © 2561 Mederic Petit. All rights reserved.
//

import UIKit
import OmiseGO

class QRCodeGeneratorViewController: BaseViewController {

    let viewModel = QRCodeGeneratorViewModel()

    let showQRCodeImageSegueIdentifier = "showQRCodeViewer"

    @IBOutlet weak var amountTextField: OMGFloatingTextField!
    @IBOutlet weak var generateButton: UIButton!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!

    override func configureView() {
        super.configureView()
        self.title = self.viewModel.title
        self.amountTextField.placeholder = self.viewModel.amountPlaceholder
        self.generateButton.setTitle(self.viewModel.generateButtonTitle, for: .normal)
        self.scanButton.setTitle(self.viewModel.scanButtonTitle, for: .normal)
    }

    override func configureViewModel() {
        super.configureViewModel()
        self.viewModel.onLoadStateChange = { $0 ? self.showLoading() : self.hideLoading()}
        self.viewModel.onSuccessGenerate = { (transactionRequest) in
            self.performSegue(withIdentifier: self.showQRCodeImageSegueIdentifier, sender: transactionRequest)
        }
        self.viewModel.onFailedGenerate = { self.showError(withMessage: $0.localizedDescription) }
        self.viewModel.onSuccessGetSettings = { self.pickerView.reloadAllComponents() }
        self.viewModel.onFailedGetSettings = { self.showError(withMessage: $0.localizedDescription) }
        self.viewModel.onGenerateButtonStateChange = {
            self.generateButton.isEnabled = $0
            self.generateButton.alpha = $0 ? 1 : 0.5
        }
        self.viewModel.onSuccessConsume = {
        self.showMessage($0)
        self.navigationController?.popViewController(animated: true)
        }
        self.viewModel.onFailedConsume = { self.showError(withMessage: $0.localizedDescription) }
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

}

extension QRCodeGeneratorViewController {

    @IBAction func tapGenerateButton(_ sender: UIButton) {
        self.viewModel.generate()
    }

    @IBAction func tapScanButton(_ sender: UIButton) {
        if let scannerVC = QRScannerViewController(delegate: self,
                                              client: SessionManager.shared.omiseGOClient,
                                              cancelButtonTitle: self.viewModel.cancelButtonTitle) {
            self.present(scannerVC, animated: true, completion: nil)
        }
    }

}

extension QRCodeGeneratorViewController: QRScannerViewControllerDelegate {

    func scannerDidCancel(scanner: QRScannerViewController) {
        scanner.dismiss(animated: true, completion: nil)
    }

    func scannerDidDecode(scanner: QRScannerViewController, transactionRequest: TransactionRequest) {
        scanner.dismiss(animated: true, completion: nil)
        self.viewModel.consume(transactionRequest: transactionRequest)
    }

    func scannerDidFailToDecode(scanner: QRScannerViewController, withError error: OmiseGOError) {
        self.showError(withMessage: error.localizedDescription)
    }

}

extension QRCodeGeneratorViewController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.viewModel.didSelect(row: row)
    }

}

extension QRCodeGeneratorViewController: UIPickerViewDataSource {

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

extension QRCodeGeneratorViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let textAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
        self.viewModel.amountStr = textAfterUpdate
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.viewModel.amountStr = ""
        return true
    }

}
