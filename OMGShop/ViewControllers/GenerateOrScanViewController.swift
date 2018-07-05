//
//  GenerateOrScanViewController.swift
//  OMGShop
//
//  Created by Mederic Petit on 3/4/18.
//  Copyright © 2017-2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO
import UIKit

class GenerateOrScanViewController: BaseViewController {
    let segueIdentifier = "showConsumeView"

    let viewModel = GenerateOrScanViewModel()

    @IBOutlet var generateQRCodeButton: UIButton!
    @IBOutlet var scanQRCodeButton: UIButton!

    override func configureView() {
        super.configureView()
        self.title = self.viewModel.title
        self.generateQRCodeButton.setTitle(self.viewModel.generateButtonTitle, for: .normal)
        self.scanQRCodeButton.setTitle(self.viewModel.scanButtonTitle, for: .normal)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == self.segueIdentifier,
            let transactionRequest = sender as? TransactionRequest,
            let vc = segue.destination as? TRequestConsumerViewController else { return }
        vc.viewModel = TRequestConsumerViewModel(transactionRequest: transactionRequest)
    }
}

extension GenerateOrScanViewController {
    @IBAction func tapScanButton(_: UIButton) {
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
        self.performSegue(withIdentifier: self.segueIdentifier, sender: transactionRequest)
    }

    func scannerDidFailToDecode(scanner _: QRScannerViewController, withError error: OMGError) {
        self.showError(withMessage: error.localizedDescription)
    }
}
