//
//  GenerateOrScanViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 3/4/18.
//  Copyright © 2018 Omise Go Ptd. Ltd. All rights reserved.
//

import OmiseGO

class GenerateOrScanViewModel: BaseViewModel {

    // Delegate closures
    var onAmountMissing: SuccessClosure?
    var onLoadStateChange: ObjectClosure<Bool>?
    var onSuccessConsume: ObjectClosure<String>?
    var onFailedConsume: FailureClosure?
    
    let title = "generate_or_scan.title".localized()
    let cancelButtonTitle = "generate_or_scan.button.title.cancel".localized()
    let generateButtonTitle = "generate_or_scan.button.title.generate".localized()
    let scanButtonTitle = "generate_or_scan.button.title.scan".localized()
    let amountMissingTitle = "generate_or_scan.alert.title.scan".localized()
    let amountMissingMessage = "generate_or_scan.alert.message.scan".localized()
    let cancelLabel = "generate_or_scan.alert.cancel".localized()
    let confirmLabel = "generate_or_scan.alert.confirm".localized()

    var amountDisplay: String = ""

    var isLoading: Bool = false {
        didSet { self.onLoadStateChange?(isLoading) }
    }

    private var transactionRequest: TransactionRequest!
    private let idemPotencyToken = UUID().uuidString
    private let transactionConsumer: TransactionConsumeProtocol

    init(transactionConsumer: TransactionConsumeProtocol = TransactionConsumeLoader()) {
        self.transactionConsumer = transactionConsumer
        super.init()
    }

    func consume(transactionRequest: TransactionRequest) {
        self.transactionRequest = transactionRequest
        if transactionRequest.amount == nil {
            self.onAmountMissing?()
        } else {
            self.performConsumption()
        }
    }

    func submitAmount() {
        self.performConsumption()
    }

    private func performConsumption() {
        guard let params = TransactionConsumptionParams(transactionRequest: self.transactionRequest,
                                                        address: nil,
                                                        mintedTokenId: nil,
                                                        amount: self.formattedAmount(),
                                                        idempotencyToken: self.idemPotencyToken,
                                                        correlationId: nil,
                                                        expirationDate: nil,
                                                        metadata: [:]) else {
                                                            self.onFailedConsume?(.unexpected)
                                                            return
        }
        self.isLoading = true
        self.transactionConsumer.consume(withParams: params) { (result) in
            self.isLoading = false
            switch result {
            case .success(data: let transactionConsume):
                self.onSuccessConsume?(
                    self.successConsumeMessage(
                        withTransacionConsume: transactionConsume
                    )
                )
            case .fail(error: let error):
                self.onFailedConsume?(.omiseGO(error: error))
            }
        }
    }

    private func successConsumeMessage(withTransacionConsume transactionConsume: TransactionConsumption) -> String {
        let formattedAmount = transactionConsume.amount / transactionConsume.mintedToken.subUnitToUnit
        //swiftlint:disable:next line_length
        return "\("qr_code_generator.message.successful_sent".localized()) \(formattedAmount) \(transactionConsume.mintedToken.symbol) \("qr_code_generator.message.to".localized()) \(transactionConsume.address)"
    }

    private func formattedAmount() -> Double? {
        guard self.amountDisplay != "",
            let amount = Double(self.amountDisplay) else { return nil }
        let formattedAmount = self.transactionRequest.mintedToken.subUnitToUnit * amount
        return Double(formattedAmount)
    }

}
