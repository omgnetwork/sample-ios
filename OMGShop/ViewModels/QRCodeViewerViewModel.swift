//
//  QRCodeViewerViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 14/2/2561 BE.
//  Copyright © 2561 Mederic Petit. All rights reserved.
//

import UIKit
import OmiseGO

class QRCodeViewerViewModel: BaseViewModel {

    let transactionRequest: TransactionRequest

    init(transactionRequest: TransactionRequest) {
        self.transactionRequest = transactionRequest
    }

    var qrImage: UIImage? {
        return self.transactionRequest.qrImage()
    }

}
