//
//  TRequestGeneratorViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 3/4/18.
//  Copyright © 2018 Omise Go Ptd. Ltd. All rights reserved.
//

import OmiseGO

class TRequestGeneratorViewModel: BaseViewModel {

    let title = "trequest_generator.title".localized()
    let iWantToLabel = "trequest_generator.label.i_want_to".localized()
    let sendLabel = "trequest_generator.label.send".localized()
    let receiveLabel = "trequest_generator.label.receive".localized()
    let tokenLabel = "trequest_generator.label.token".localized()
    let amountLabel = "trequest_generator.label.amount".localized()
    let addressLabel = "trequest_generator.label.address".localized()
    let correlationIdLabel = "trequest_generator.label.correlation_id".localized()
    let requiresConfirmationLabel = "trequest_generator.label.requires_confirmation".localized()
    let maxConsumptionLabel = "trequest_generator.label.max_consumption".localized()
    let consumptionLifetimeLabel = "trequest_generator.label.consumption_lifetime".localized()
    let expirationDateLabel = "trequest_generator.label.expiration_date".localized()
    let allowAmountOverrideLabel = "trequest_generator.label.allow_amount_override".localized()
    let generateButtonTitle = "trequest_generator.button.title.generate".localized()
    let nextButtonTitle = "trequest_generator.button.title.next".localized()

    // Delegate closures
    var onSuccessGenerate: ObjectClosure<TransactionRequest>?
    var onFailedGenerate: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?
    var onSuccessGetSettings: SuccessClosure?
    var onFailedGetSettings: FailureClosure?
    var onGenerateButtonStateChange: ObjectClosure<Bool>?

    private var type: TransactionRequestType = .receive
    private var mintedToken: MintedToken? {
        didSet {
            self.mintedTokenDisplay = mintedToken?.symbol ?? ""
        }
    }
    private var expirationDate: Date? {
        didSet {
            guard let date = expirationDate else { return }
            self.expirationDateDisplay = date.toString(withFormat: "dd MMM yyyy - HH:mm")
        }
    }

    var sendReceiveSwitchState: Bool
    var mintedTokenDisplay: String
    var amountDisplay: String
    var addressDisplay: String
    var correlationIdDisplay: String
    var requiresConfirmationSwitchState: Bool
    var maxConsumptionsDisplay: String
    var consumptionLifetimeDisplay: String
    var expirationDateDisplay: String
    var allowAmountOverrideSwitchState: Bool

    private var settings: Setting? {
        didSet {
            self.mintedToken = settings?.mintedTokens.first
        }
    }

    private let settingLoader: SettingLoaderProtocol
    private let transactionRequestCreator: TransactionRequestCreateProtocol

    var isGenerateButtonEnabled: Bool = false {
        didSet { self.onGenerateButtonStateChange?(isGenerateButtonEnabled) }
    }
    var isLoading: Bool = false {
        didSet { self.onLoadStateChange?(isLoading) }
    }

    init(settingLoader: SettingLoaderProtocol = SettingLoader(),
         transactionRequestCreator: TransactionRequestCreateProtocol = TransactionRequestLoader()) {
        self.settingLoader = settingLoader
        self.transactionRequestCreator = transactionRequestCreator
        self.sendReceiveSwitchState = self.type == .send
        self.mintedTokenDisplay = ""
        self.amountDisplay = ""
        self.addressDisplay = ""
        self.correlationIdDisplay = ""
        self.requiresConfirmationSwitchState = true
        self.maxConsumptionsDisplay =  ""
        self.consumptionLifetimeDisplay = ""
        self.expirationDateDisplay = ""
        self.allowAmountOverrideSwitchState = true
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

    func generateTransactionRequest() {
        guard let mintedTokenId = self.mintedToken?.id else { return }
        guard let params = TransactionRequestCreateParams(type: self.sendReceiveSwitchState ? .send : .receive,
                                                          mintedTokenId: mintedTokenId,
                                                          amount: self.formattedAmount(),
                                                          address: self.addressDisplay != "" ? self.addressDisplay : nil,
                                                          correlationId: self.correlationIdDisplay != "" ? self.correlationIdDisplay : nil,
                                                          requireConfirmation: self.requiresConfirmationSwitchState,
                                                          maxConsumptions: self.formattedMaxConsumptions(),
                                                          consumptionLifetime: self.formattedConsumptionLifetime(),
                                                          expirationDate: self.expirationDate,
                                                          allowAmountOverride: self.allowAmountOverrideSwitchState,
                                                          metadata: [:]
            ) else {
                self.onFailedGenerate?(.message(message: "trequest_generator.error.missing_amount".localized()))
                return
        }
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

    private func updateGenerateButtonState() {
        guard self.mintedToken != nil else {
            self.isGenerateButtonEnabled = false
            return
        }
        self.isGenerateButtonEnabled = true
    }

    private func formattedAmount() -> Double? {
        guard let subUnitToUnit = self.mintedToken?.subUnitToUnit,
            self.amountDisplay != "",
            let amount = Double(self.amountDisplay) else { return nil }
        let formattedAmount = subUnitToUnit * amount
        return Double(formattedAmount)
    }

    private func formattedMaxConsumptions() -> Int? {
        guard self.maxConsumptionsDisplay != "",
            let maxConsumptions = Int(self.maxConsumptionsDisplay) else {
                return nil
        }
        return maxConsumptions
    }

    private func formattedConsumptionLifetime() -> Int? {
        guard self.consumptionLifetimeDisplay != "",
            let consumptionLifetime = Int(self.consumptionLifetimeDisplay) else {
                return nil
        }
        return consumptionLifetime
    }

    func didUpdateExpirationDate(_ expirationDate: Date) {
        self.expirationDate = expirationDate
    }

    // MARK: Picker
    func didSelect(row: Int) {
        self.mintedToken = self.settings?.mintedTokens[row]
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
