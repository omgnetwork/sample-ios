//
//  QRCodeGeneratorViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 13/2/18.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

import OmiseGO
import BigInt

class QRCodeGeneratorViewModel: BaseViewModel {

    // Delegate closures
    var onSuccessGenerate: ObjectClosure<TransactionRequest>?
    var onFailedGenerate: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?
    var onSuccessGetSettings: SuccessClosure?
    var onFailedGetSettings: FailureClosure?
    var onGenerateButtonStateChange: ObjectClosure<Bool>?
    var onSuccessConsume: ObjectClosure<String>?
    var onFailedConsume: FailureClosure?

    private var settings: Setting? {
        didSet {
            self.selectedMintedToken = settings?.mintedTokens.first
        }
    }
    private var selectedMintedToken: MintedToken?
    private let idemPotencyToken = UUID().uuidString
    private let settingLoader: SettingLoaderProtocol
    private let transactionRequestCreator: TransactionRequestCreateProtocol
    private let transactionConsumer: TransactionConsumeProtocol

    let title = "qr_code_generator.title".localized()
    let amountPlaceholder = "qr_code_generator.text_field.placeholder.amount".localized()
    let scanButtonTitle = "qr_code_generator.button.title.scan".localized()
    let cancelButtonTitle = "qr_code_scanner.button.title.cancel".localized()
    let generateButtonTitle = "qr_code_generator.button.title.generate".localized()

    var isGenerateButtonEnabled: Bool = false {
        didSet { self.onGenerateButtonStateChange?(isGenerateButtonEnabled) }
    }
    var isLoading: Bool = false {
        didSet { self.onLoadStateChange?(isLoading) }
    }
    var amountStr: String? {
        didSet {
            self.updateGenerateButtonState()
        }
    }

    init(settingLoader: SettingLoaderProtocol = SettingLoader(),
         transactionRequestCreator: TransactionRequestCreateProtocol = TransactionRequestLoader(),
         transactionConsumer: TransactionConsumeProtocol = TransactionConsumeLoader()) {
        self.settingLoader = settingLoader
        self.transactionRequestCreator = transactionRequestCreator
        self.transactionConsumer = transactionConsumer
        super.init()
    }

    func loadSettings() {
        self.isLoading = true
        self.settingLoader.get { (result) in
            self.isLoading = false
            switch result {
            case .success(data: let settings):
                self.settings = settings
                self.onSuccessGetSettings?()
            case .fail(error: let error):
                self.handleOMGError(error)
                self.onFailedGetSettings?(.omiseGO(error: error))
            }
            self.updateGenerateButtonState()
        }
    }

    func generate() {
        guard let mintedTokenId = self.selectedMintedToken?.id else { return }
        let params = TransactionRequestCreateParams(type: .receive,
                                                    mintedTokenId: mintedTokenId,
                                                    amount: self.formattedAmount(),
                                                    address: nil,
                                                    correlationId: nil,
                                                    requireConfirmation: false,
                                                    maxConsumptions: nil,
                                                    consumptionLifetime: nil,
                                                    expirationDate: nil,
                                                    allowAmountOverride: true,
                                                    metadata: [:])!
        self.isLoading = true
        self.transactionRequestCreator.generate(withParams: params) { (result) in
            self.isLoading = false
            switch result {
            case .success(data: let transactionRequest):
                self.onSuccessGenerate?(transactionRequest)
            case .fail(error: let error):
                self.onFailedGenerate?(.omiseGO(error: error))
            }
        }
    }

    func consume(transactionRequest: TransactionRequest) {
        guard let params = TransactionConsumptionParams(transactionRequest: transactionRequest,
                                                    address: nil,
                                                    mintedTokenId: nil,
                                                    amount: nil,
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

    private func updateGenerateButtonState() {
        guard self.selectedMintedToken != nil, let amount = self.amountStr, Double(amount) != nil else {
            self.isGenerateButtonEnabled = false
            return
        }
        self.isGenerateButtonEnabled = true
    }

    private func formattedAmount() -> Double? {
        guard let subUnitToUnit = self.selectedMintedToken?.subUnitToUnit,
            let amountStr = self.amountStr,
            let amount = Double(amountStr) else { return nil }
        let formattedAmount = subUnitToUnit * amount
        return Double(formattedAmount)
    }

    private func successConsumeMessage(withTransacionConsume transactionConsume: TransactionConsumption) -> String {
        let formattedAmount = transactionConsume.amount / transactionConsume.mintedToken.subUnitToUnit
        //swiftlint:disable:next line_length
        return "\("qr_code_generator.message.successful_sent".localized()) \(formattedAmount) \(transactionConsume.mintedToken.symbol) \("qr_code_generator.message.to".localized()) \(transactionConsume.address)"
    }

    // MARK: Picker
    func didSelect(row: Int) {
        self.selectedMintedToken = self.settings?.mintedTokens[row]
    }

    func numberOfRowsInPicker() -> Int {
        return self.settings?.mintedTokens.count ?? 0
    }

    func numberOfColumnsInPicker() -> Int {
        return 1
    }

    func title(forRow row: Int) -> String? {
        return self.settings?.mintedTokens[row].name
    }

}
