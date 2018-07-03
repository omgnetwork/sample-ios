//
//  QRCodeViewerViewController.swift
//  OMGShop
//
//  Created by Mederic Petit on 13/2/18.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

import UIKit

class QRCodeViewerViewController: BaseViewController {
    var viewModel: QRCodeViewerViewModel!
    @IBOutlet var qrImageView: UIImageView!

    @IBOutlet var waitingForScanLabel: UILabel!

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.viewModel.stopListening()
    }

    override func configureView() {
        super.configureView()
        self.waitingForScanLabel.text = self.viewModel.waitingLabel
        self.qrImageView.image = self.viewModel.transactionRequest.qrImage()
    }

    override func configureViewModel() {
        super.configureViewModel()
        self.viewModel.onConsumptionRequest = {
            self.present(self.setupAlertController(), animated: true, completion: nil)
        }
        self.viewModel.onFailApprove = { self.showError(withMessage: $0.message) }
        self.viewModel.onFailReject = { self.showError(withMessage: $0.message) }
        self.viewModel.onSuccessApprove = { self.showMessage($0) }
        self.viewModel.onSuccessReject = { self.showMessage($0) }
        self.viewModel.onLoadStateChange = { $0 ? self.showLoading() : self.hideLoading() }
    }

    func setupAlertController() -> UIAlertController {
        let alert = UIAlertController(title: self.viewModel.consumptionRequestTitle,
                                      message: self.viewModel.consumptionRequestMessage(),
                                      preferredStyle: .alert)
        let rejectAction = UIAlertAction(title: self.viewModel.rejectButtonTitle, style: .destructive, handler: { [weak self] _ in
            self?.viewModel.reject()
            alert.dismiss(animated: true, completion: nil)
        })
        let approveAction = UIAlertAction(title: self.viewModel.approveButtonTitle, style: .default, handler: { [weak self] _ in
            self?.viewModel.approve()
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(rejectAction)
        alert.addAction(approveAction)
        return alert
    }
}
