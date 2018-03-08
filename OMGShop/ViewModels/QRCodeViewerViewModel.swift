//
//  QRCodeViewerViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 14/2/18.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
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
