//
//  GenerateOrScanViewController.swift
//  OMGShop
//
//  Created by Mederic Petit on 3/4/18.
//  Copyright © 2018 Omise Go Ptd. Ltd. All rights reserved.
//

import UIKit
import OmiseGO

class GenerateOrScanViewController: BaseViewController {

    let viewModel = GenerateOrScanViewModel()

    @IBOutlet weak var generateQRCodeButton: UIButton!
    @IBOutlet weak var scanQRCodeButton: UIButton!

    override func configureView() {
        super.configureView()
        self.title = self.viewModel.title
        self.generateQRCodeButton.setTitle(self.viewModel.generateButtonTitle, for: .normal)
        self.scanQRCodeButton.setTitle(self.viewModel.scanButtonTitle, for: .normal)
    }

    override func configureViewModel() {
        super.configureViewModel()
        self.viewModel.onLoadStateChange = { $0 ? self.showLoading() : self.hideLoading()}
        self.viewModel.onAmountMissing = {
            let alert = UIAlertController(title: self.viewModel.amountMissingTitle,
                                          message: self.viewModel.amountMissingMessage,
                                          preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: self.viewModel.cancelLabel, style: .cancel, handler: nil)
            let confirmAction = UIAlertAction(title: self.viewModel.confirmLabel, style: .default, handler: { _ in
                self.viewModel.amountDisplay = alert.textFields?.first?.text ?? ""
                self.viewModel.submitAmount()
            })
            alert.addTextField(configurationHandler: { (textField) in
                textField.font = Font.avenirBook.withSize(15)
                textField.keyboardType = .decimalPad
            })
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
            self.present(alert, animated: true, completion: nil)
        }
        self.viewModel.onSuccessConsume = {
            self.showMessage($0)
            self.navigationController?.popViewController(animated: true)
        }
        self.viewModel.onFailedConsume = { self.showError(withMessage: $0.localizedDescription) }
    }

}

extension GenerateOrScanViewController {

    @IBAction func tapScanButton(_ sender: UIButton) {
        if let scannerVC = QRScannerViewController(delegate: self,
                                                   client: SessionManager.shared.omiseGOClient,
                                                   cancelButtonTitle: self.viewModel.cancelButtonTitle) {
            self.present(scannerVC, animated: true, completion: nil)
        }
    }

}

extension GenerateOrScanViewController: QRScannerViewControllerDelegate {

    func scannerDidCancel(scanner: QRScannerViewController) {
        scanner.dismiss(animated: true, completion: nil)
    }

    func scannerDidDecode(scanner: QRScannerViewController, transactionRequest: TransactionRequest) {
        scanner.dismiss(animated: true, completion: nil)
        self.viewModel.consume(transactionRequest: transactionRequest)
    }

    func scannerDidFailToDecode(scanner: QRScannerViewController, withError error: OMGError) {
        self.showError(withMessage: error.localizedDescription)
    }

}
