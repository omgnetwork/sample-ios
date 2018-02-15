//
//  QRCodeGeneratorViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 13/2/2561 BE.
//  Copyright © 2561 Mederic Petit. All rights reserved.
//

import OmiseGO
import BigInt

class QRCodeGeneratorViewModel: BaseViewModel {

    var onSuccessGenerate: ObjectClosure<TransactionRequest>?
    var onFailedGenerate: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?
    var onSuccessGetSettings: SuccessClosure?
    var onFailedGetSettings: FailureClosure?
    var onGenerateButtonStateChange: ObjectClosure<Bool>?

    var amountStr: String? {
        didSet {
            self.updateGenerateButtonState()
        }
    }
    private var settings: Setting? {
        didSet {
            self.selectedMintedToken = settings?.mintedTokens.first
        }
    }
    private var selectedMintedToken: MintedToken?

    let title = "qr_code_generator.title".localized()
    let amountPlaceholder = "qr_code_generator.text_field.placeholder.amount".localized()
    let scanButtonTitle = "qr_code_generator.button.title.scan".localized()

    var generateButtonTitle = "qr_code_generator.button.title.generate".localized()

    private let settingLoader: SettingLoaderProtocol

    var isGenerateButtonEnabled: Bool = false {
        didSet { self.onGenerateButtonStateChange?(isGenerateButtonEnabled) }
    }
    var isLoading: Bool = false {
        didSet { self.onLoadStateChange?(isLoading) }
    }

    init(settingLoader: SettingLoaderProtocol = SettingLoader()) {
        self.settingLoader = settingLoader
        super.init()
        self.loadSettings()
    }

    func generate() {
        guard let mintedTokenId = self.selectedMintedToken?.id else { return }
        let params = TransactionRequestCreateParams(type: .receive,
                                                    mintedTokenId: mintedTokenId,
                                                    amount: self.formatedAmount(),
                                                    address: nil,
                                                    correlationId: nil)
        self.isLoading = true
        TransactionRequest.generateTransactionRequest(using: SessionManager.shared.omiseGOClient,
                                                      params: params) { (result) in
            self.isLoading = false
            switch result {
            case .success(data: let transactionRequest):
                self.onSuccessGenerate?(transactionRequest)
            case .fail(error: let error):
                self.onFailedGenerate?(.omiseGO(error: error))
            }
        }
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
                self.handleOmiseGOrror(error)
                self.onFailedGetSettings?(.omiseGO(error: error))
            }
            self.updateGenerateButtonState()
        }
    }

    private func updateGenerateButtonState() {
        guard self.selectedMintedToken != nil, let amount = self.amountStr, Double(amount) != nil else {
            self.isGenerateButtonEnabled = false
            return
        }
        self.isGenerateButtonEnabled = true
    }

    private func formatedAmount() -> Double? {
        guard let subUnitToUnit = self.selectedMintedToken?.subUnitToUnit,
            let amountStr = self.amountStr,
            let amount = Double(amountStr) else { return nil }
        let formattedAmount = subUnitToUnit * amount
        return Double(formattedAmount)
    }

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