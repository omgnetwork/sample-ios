//
//  TRequestGeneratorViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 3/4/18.
//  Copyright © 2018 Omise Go Ptd. Ltd. All rights reserved.
//

import OmiseGO

class TRequestGeneratorViewModel: BaseViewModel {

    enum Picker {
        case token
        case address
    }

    let title = "trequest_generator.title".localized()
    let iWantToLabel = "trequest_generator.label.i_want_to".localized()
    let sendLabel = "trequest_generator.label.send".localized()
    let receiveLabel = "trequest_generator.label.receive".localized()
    let tokenLabel = "trequest_generator.label.token".localized()
    let amountLabel = "trequest_generator.label.amount".localized()
    let addressLabel = "trequest_generator.label.address".localized()
    let correlationIdLabel = "trequest_generator.label.correlation_id".localized()
    let requiresConfirmationLabel = "trequest_generator.label.requires_confirmation".localized()
    let maxConsumptionLabel = "trequest_generator.label.max_consumptions".localized()
    let maxConsumptionsPerUserLabel = "trequest_generator.label.max_consumptions_per_user".localized()
    let consumptionLifetimeLabel = "trequest_generator.label.consumption_lifetime".localized()
    let expirationDateLabel = "trequest_generator.label.expiration_date".localized()
    let allowAmountOverrideLabel = "trequest_generator.label.allow_amount_override".localized()
    let generateButtonTitle = "trequest_generator.button.title.generate".localized()

    // Delegate closures
    var onSuccessGenerate: ObjectClosure<TransactionRequest>?
    var onFailedGenerate: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?
    var onSuccessGetSettings: SuccessClosure?
    var onFailedGetSettings: FailureClosure?
    var onSuccessGetWallets: SuccessClosure?
    var onFailedLoadWallet: FailureClosure?
    var onGenerateButtonStateChange: ObjectClosure<Bool>?

    private var type: TransactionRequestType = .receive
    private var token: Token? {
        didSet {
            self.tokenDisplay = token?.symbol ?? ""
        }
    }
    private var wallet: Wallet? {
        didSet {
            self.addressDisplay = wallet?.address ?? ""
        }
    }
    private var expirationDate: Date? {
        didSet {
            guard let date = expirationDate else { return }
            self.expirationDateDisplay = date.toString(withFormat: "dd MMM yyyy - HH:mm")
        }
    }

    var sendReceiveSwitchState: Bool
    var tokenDisplay: String = ""
    var amountDisplay: String = ""
    var addressDisplay: String = ""
    var correlationIdDisplay: String = ""
    var requiresConfirmationSwitchState: Bool = true
    var maxConsumptionsDisplay: String = ""
    var maxConsumptionsPerUserDisplay: String = ""
    var consumptionLifetimeDisplay: String = ""
    var expirationDateDisplay: String = ""
    var allowAmountOverrideSwitchState: Bool = true

    private var settings: Setting? {
        didSet {
            self.token = settings?.tokens.first
        }
    }
    private var wallets: [Wallet] = [] {
        didSet {
            self.wallet = wallets.first
        }
    }

    private let settingLoader: SettingLoaderProtocol
    private let walletLoader: WalletLoaderProtocol
    private let transactionRequestCreator: TransactionRequestCreateProtocol

    var isGenerateButtonEnabled: Bool = false {
        didSet { self.onGenerateButtonStateChange?(isGenerateButtonEnabled) }
    }
    var isLoading: Bool = false {
        didSet { self.onLoadStateChange?(isLoading) }
    }

    init(settingLoader: SettingLoaderProtocol = SettingLoader(),
         walletLoader: WalletLoaderProtocol = WalletLoader(),
         transactionRequestCreator: TransactionRequestCreateProtocol = TransactionRequestLoader()) {
        self.settingLoader = settingLoader
        self.walletLoader = walletLoader
        self.transactionRequestCreator = transactionRequestCreator
        self.sendReceiveSwitchState = self.type == .send
        super.init()
    }

    func loadData() {
        self.isLoading = true
        let loadingGroup = DispatchGroup()
        loadingGroup.enter()
        self.loadSettings(withGroup: loadingGroup)
        loadingGroup.enter()
        self.loadWallets(withGroup: loadingGroup)
        DispatchQueue.global().async {
            loadingGroup.wait()
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }

    func generateTransactionRequest() {
        guard let tokenId = self.token?.id else { return }
        guard let params = TransactionRequestCreateParams(type: self.sendReceiveSwitchState ? .send : .receive,
                                                          tokenId: tokenId,
                                                          amount: self.token?.formattedAmount(forAmount: self.amountDisplay),
                                                          address: self.addressDisplay != "" ? self.addressDisplay : nil,
                                                          correlationId: self.correlationIdDisplay != "" ? self.correlationIdDisplay : nil,
                                                          requireConfirmation: self.requiresConfirmationSwitchState,
                                                          maxConsumptions: self.formattedMaxConsumptions(),
                                                          consumptionLifetime: self.formattedConsumptionLifetime(),
                                                          expirationDate: self.expirationDate,
                                                          allowAmountOverride: self.allowAmountOverrideSwitchState,
                                                          maxConsumptionsPerUser: self.formattedMaxConsumptionsPerUser(),
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

    private func loadWallets(withGroup group: DispatchGroup?) {
        self.walletLoader.getAll { (result) in
            defer { group?.leave() }
            switch result {
            case .success(data: let wallets):
                self.wallets = wallets
                self.onSuccessGetWallets?()
            case .fail(error: let error):
                self.handleOMGError(error)
                self.onFailedLoadWallet?(.omiseGO(error: error))
            }
        }
    }

    private func loadSettings(withGroup group: DispatchGroup?) {
        self.settingLoader.get { (result) in
            defer { group?.leave() }
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
        guard self.token != nil else {
            self.isGenerateButtonEnabled = false
            return
        }
        self.isGenerateButtonEnabled = true
    }

    private func formattedMaxConsumptions() -> Int? {
        guard self.maxConsumptionsDisplay != "",
            let maxConsumptions = Int(self.maxConsumptionsDisplay) else {
                return nil
        }
        return maxConsumptions
    }

    private func formattedMaxConsumptionsPerUser() -> Int? {
        guard self.maxConsumptionsPerUserDisplay != "",
            let maxConsumptionsPerUser = Int(self.maxConsumptionsPerUserDisplay) else {
                return nil
        }
        return maxConsumptionsPerUser
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
    func didSelect(row: Int, picker: Picker) {
        switch picker {
        case .token: self.token = self.settings?.tokens[row]
        case .address: self.wallet = self.wallets[row]
        }
    }

    func numberOfRows(inPicker picker: Picker) -> Int {
        switch picker {
        case .token: return self.settings?.tokens.count ?? 0
        case .address: return self.wallets.count
        }

    }

    func numberOfColumnsInPicker() -> Int {
        return 1
    }

    func title(forRow row: Int, picker: Picker) -> String? {
        switch picker {
        case .token: return self.settings?.tokens[row].name
        case .address: return self.wallets[row].address
        }
    }
}
