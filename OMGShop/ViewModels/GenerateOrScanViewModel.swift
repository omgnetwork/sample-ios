//
//  GenerateOrScanViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 3/4/18.
//  Copyright © 2018 Omise Go Ptd. Ltd. All rights reserved.
//

import OmiseGO

class GenerateOrScanViewModel: BaseViewModel {

    let title = "generate_or_scan.title".localized()
    let cancelButtonTitle = "generate_or_scan.button.title.cancel".localized()
    let generateButtonTitle = "generate_or_scan.button.title.generate".localized()
    let scanButtonTitle = "generate_or_scan.button.title.scan".localized()

    func consume(transactionRequest: TransactionRequest) {
        // TODO: Handle consumption
//        guard let params = TransactionConsumptionParams(transactionRequest: transactionRequest,
//                                                        address: nil,
//                                                        mintedTokenId: nil,
//                                                        amount: nil,
//                                                        idempotencyToken: self.idemPotencyToken,
//                                                        correlationId: nil,
//                                                        expirationDate: nil,
//                                                        metadata: [:]) else {
//                                                            self.onFailedConsume?(.unexpected)
//                                                            return
//        }
//        self.isLoading = true
//        self.transactionConsumer.consume(withParams: params) { (result) in
//            self.isLoading = false
//            switch result {
//            case .success(data: let transactionConsume):
//                self.onSuccessConsume?(
//                    self.successConsumeMessage(
//                        withTransacionConsume: transactionConsume
//                    )
//                )
//            case .fail(error: let error):
//                self.onFailedConsume?(.omiseGO(error: error))
//            }
//        }
    }

}
