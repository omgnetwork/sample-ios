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
    @IBOutlet weak var qrImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.qrImageView.image = self.viewModel.transactionRequest.qrImage()
    }

}
