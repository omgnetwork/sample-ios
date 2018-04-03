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
    let generateButtonTitle = "trequest_generator.button.title.generate".localized()

    // Delegate closures
    var onSuccessGenerate: ObjectClosure<TransactionRequest>?
    var onFailedGenerate: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?
    var onSuccessGetSettings: SuccessClosure?
    var onFailedGetSettings: FailureClosure?
    var onGenerateButtonStateChange: ObjectClosure<Bool>?

    private var type: TransactionRequestType = .receive
    private var mintedToken: MintedToken?
    private var amount: Double?
    private var address: String?
    private var correlationId: String?
    private var requireConfirmation: Bool = true
    private var maxConsumptions: Int?
    private var consumptionLifetime: Int?
    private var expirationDate: Date?
    private var allowAmountOverride: Bool = true

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

    private func updateGenerateButtonState() {
        guard self.mintedToken != nil else {
            self.isGenerateButtonEnabled = false
            return
        }
        self.isGenerateButtonEnabled = true
    }

//    private func formattedAmount() -> Double? {
//        guard let subUnitToUnit = self.mintedToken?.subUnitToUnit,
//            let amountStr = self.amountStr,
//            let amount = Double(amountStr) else { return nil }
//        let formattedAmount = subUnitToUnit * amount
//        return Double(formattedAmount)
//    }
}
