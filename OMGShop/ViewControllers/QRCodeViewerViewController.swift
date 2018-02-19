//
//  QRCodeViewerViewController.swift
//  OMGShop
//
//  Created by Mederic Petit on 13/2/2561 BE.
//  Copyright © 2561 Mederic Petit. All rights reserved.
//

import UIKit

class QRCodeViewerViewController: BaseViewController {

    var viewModel: QRCodeViewerViewModel!
    @IBOutlet weak var qrImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.qrImageView.image = self.viewModel.transactionRequest.qrImage()
    }

}
