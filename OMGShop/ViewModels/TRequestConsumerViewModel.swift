//
//  TRequestConsumerViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 5/4/18.
//  Copyright © 2018 Omise Go Ptd. Ltd. All rights reserved.
//

import OmiseGO
import BigInt

class TRequestConsumerViewModel: BaseViewModel {

    enum Picker {
        case token
        case address
    }

    let title = "trequest_consumer.title".localized()
    let consumeButtonTitle = "trequest_consumer.button.title.consume".localized()

    let tokenLabel = "trequest_consumer.label.token".localized()
    let amountLabel = "trequest_consumer.label.amount".localized()
    let addressLabel = "trequest_consumer.label.address".localized()
    let correlationIdLabel = "trequest_consumer.label.correlation_id".localized()

    // Delegate closures
    var onLoadStateChange: ObjectClosure<Bool>?
    var onSuccessConsume: ObjectClosure<String>?
    var onFailedConsume: FailureClosure?
    var onSuccessGetSettings: SuccessClosure?
    var onFailedGetSettings: FailureClosure?
    var onSuccessGetWallets: SuccessClosure?
    var onFailedLoadWallet: FailureClosure?
    var onConsumeButtonStateChange: ObjectClosure<Bool>?
    var onPendingConfirmation: ObjectClosure<String>?
    var onTokenChange: ObjectClosure<String>?

    var tokenDisplay: String {
        didSet {
            self.onTokenChange?(tokenDisplay)
        }
    }
    var amountDisplay: String
    var addressDisplay: String = ""
    var correlationIdDisplay: String = ""
    let transactionTypeDisplay: String
    let requesterAddressDisplay: String

    var isLoading: Bool = false {
        didSet { self.onLoadStateChange?(isLoading) }
    }
    var isConsumeButtonEnabled: Bool = false {
        didSet { self.onConsumeButtonStateChange?(isConsumeButtonEnabled) }
    }
    var isAmountEnabled: Bool {
        return self.transactionRequest.allowAmountOverride
    }
    var isTokenEnabled: Bool = false

    private let transactionRequest: TransactionRequest
    private var transactionConsumption: TransactionConsumption?
    private var idemPotencyToken = UUID().uuidString

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
    private var settings: Setting? {
        didSet {
            self.isTokenEnabled = true
            self.token = self.settings?.tokens.filter({$0 == self.transactionRequest.token}).first
        }
    }
    private var wallets: [Wallet] = [] {
        didSet {
            self.wallet = wallets.first
        }
    }

    private let settingLoader: SettingLoaderProtocol
    private let walletLoader: WalletLoaderProtocol
    private let transactionConsumer: TransactionConsumeProtocol

    init(transactionRequest: TransactionRequest,
         transactionConsumer: TransactionConsumeProtocol = TransactionConsumeLoader(),
         walletLoader: WalletLoaderProtocol = WalletLoader(),
         settingLoader: SettingLoaderProtocol = SettingLoader()) {
        self.transactionRequest = transactionRequest
        self.transactionConsumer = transactionConsumer
        self.settingLoader = settingLoader
        self.walletLoader = walletLoader
        self.token = transactionRequest.token
        self.tokenDisplay = transactionRequest.token.symbol
        if let amount = transactionRequest.amount {
            let formatter = OMGNumberFormatter(precision: 5)
            self.amountDisplay = formatter.string(from: amount,
                                                  subunitToUnit: transactionRequest.token.subUnitToUnit)
        } else {
            self.amountDisplay = ""
        }
        self.transactionTypeDisplay = transactionRequest.type == .send ?
            "trequest_consumer.label.receive_from".localized() :
            "trequest_consumer.label.send_to".localized()
        self.requesterAddressDisplay = transactionRequest.address
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

    func consumeTransactionRequest() {
        guard let tokenId = self.token?.id else { return }

        guard let params = TransactionConsumptionParams(
            transactionRequest: self.transactionRequest,
            address: self.addressDisplay != "" ? self.addressDisplay : nil,
            tokenId: tokenId,
            amount: self.token?.formattedAmount(forAmount: self.amountDisplay),
            idempotencyToken: self.idemPotencyToken,
            correlationId: self.correlationIdDisplay != "" ? self.correlationIdDisplay : nil,
            metadata: [:]) else {
                self.onFailedConsume?(.missingRequiredFields)
                return
        }
        self.isLoading = true
        self.transactionConsumer.consume(withParams: params) { (result) in
            self.isLoading = false
            switch result {
            case .success(data: let transactionConsumption):
                self.idemPotencyToken = UUID().uuidString
                self.transactionConsumption = transactionConsumption
                if self.transactionRequest.requireConfirmation {
                    self.onPendingConfirmation?("transaction_consumer.message.waiting_for_confirmation".localized())
                    transactionConsumption.startListeningEvents(withClient: SessionManager.shared.omiseGOSocketClient, eventDelegate: self)
                } else {
                    self.onSuccessConsume?(
                        self.successConsumeMessage(withTransacionConsumption: transactionConsumption)
                    )
                }
            case .fail(error: let error):
                self.onFailedConsume?(.omiseGO(error: error))
            }
        }
    }

    private func successConsumeMessage(withTransacionConsumption transactionConsumption: TransactionConsumption) -> String {
        let formatter = OMGNumberFormatter(precision: 5)
        let formattedAmount = formatter.string(from: transactionConsumption.amount,
                                               subunitToUnit: transactionConsumption.token.subUnitToUnit)
        if transactionConsumption.transactionRequest.type == .send {
            //swiftlint:disable:next line_length
            return "\("trequest_consumer.message.successfully".localized()) \("trequest_consumer.message.received".localized()) \(formattedAmount) \(transactionConsumption.token.symbol) \("trequest_consumer.message.from".localized()) \(transactionConsumption.transactionRequest.address)"
        } else {
            //swiftlint:disable:next line_length
            return "\("trequest_consumer.message.successfully".localized()) \("trequest_consumer.message.sent".localized()) \(formattedAmount) \(transactionConsumption.token.symbol) \("trequest_consumer.message.to".localized()) \(transactionConsumption.transactionRequest.address)"
        }
    }

    private func updateConsumeButtonState() {
        guard self.token != nil else {
            self.isConsumeButtonEnabled = false
            return
        }
        self.isConsumeButtonEnabled = true
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
            self.updateConsumeButtonState()
        }
    }

    func stopListening() {
        self.transactionConsumption?.stopListening(withClient: SessionManager.shared.omiseGOSocketClient)
    }

    // MARK: Picker
    func didSelect(row: Int, picker: Picker) {
        switch picker {
        case .token: self.token = self.settings?.tokens[row]
        case .address: self.wallet = self.wallets[row]
        }
    }

    func selectedRow(forPicker picker: Picker) -> Int {
        switch picker {
        case .token:
            guard let token = self.token, let settings = self.settings else { return 0 }
            return settings.tokens.index(of: token) ?? 0
        case .address:
            guard let wallet = self.wallet else { return 0 }
            return self.wallets.index(of: wallet) ?? 0
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

extension TRequestConsumerViewModel: TransactionConsumptionEventDelegate {

    func onSuccessfulTransactionConsumptionFinalized(_ transactionConsumption: TransactionConsumption) {
        switch transactionConsumption.status {
        case .confirmed: self.onSuccessConsume?(self.successConsumeMessage(withTransacionConsumption: transactionConsumption))
        case .rejected: self.onFailedConsume?(OMGShopError.message(message: "trequest_consumer.error.consumption_rejected".localized()))
        default: break
        }
        self.isLoading = false
    }

    func onFailedTransactionConsumptionFinalized(_ transactionConsumption: TransactionConsumption, error: OmiseGO.APIError) {
        self.onFailedConsume?(OMGShopError.omiseGO(error: OMGError.api(apiError: error)))
        self.isLoading = false
    }

    func didStartListening() {
        print("Did start listening")
    }

    func didStopListening() {
        print("Did stop listening")
    }

    func onError(_ error: OmiseGO.APIError) {
        print("Did receive error: \(error.description)")
    }

}
