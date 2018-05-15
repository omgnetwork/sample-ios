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
        case mintedToken
        case address
    }

    let title = "trequest_consumer.title".localized()
    let consumeButtonTitle = "trequest_consumer.button.title.consume".localized()

    let tokenLabel = "trequest_consumer.label.token".localized()
    let amountLabel = "trequest_consumer.label.amount".localized()
    let addressLabel = "trequest_consumer.label.address".localized()
    let correlationIdLabel = "trequest_consumer.label.correlation_id".localized()
    let expirationDateLabel = "trequest_consumer.label.expiration_date".localized()

    // Delegate closures
    var onLoadStateChange: ObjectClosure<Bool>?
    var onSuccessConsume: ObjectClosure<String>?
    var onFailedConsume: FailureClosure?
    var onSuccessGetSettings: SuccessClosure?
    var onFailedGetSettings: FailureClosure?
    var onSuccessGetAddresses: SuccessClosure?
    var onFailedLoadAddress: FailureClosure?
    var onConsumeButtonStateChange: ObjectClosure<Bool>?
    var onPendingConfirmation: ObjectClosure<String>?

    var mintedTokenDisplay: String
    var amountDisplay: String
    var addressDisplay: String = ""
    var correlationIdDisplay: String = ""
    var expirationDateDisplay: String = ""
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
    var isTokenEnabled: Bool { return false }

    private let transactionRequest: TransactionRequest
    private var transactionConsumption: TransactionConsumption?
    private let idemPotencyToken = UUID().uuidString

    private var mintedToken: MintedToken? {
        didSet {
            self.mintedTokenDisplay = mintedToken?.symbol ?? ""
        }
    }
    private var address: Address? {
        didSet {
            self.addressDisplay = address?.address ?? ""
        }
    }
    private var expirationDate: Date? {
        didSet {
            guard let date = expirationDate else { return }
            self.expirationDateDisplay = date.toString(withFormat: "dd MMM yyyy - HH:mm")
        }
    }
    private var settings: Setting? {
        didSet {
            self.mintedToken = settings?.mintedTokens.first
        }
    }
    private var addresses: [Address] = [] {
        didSet {
            self.address = addresses.first
        }
    }

    private let settingLoader: SettingLoaderProtocol
    private let addressLoader: AddressLoaderProtocol
    private let transactionConsumer: TransactionConsumeProtocol

    init(transactionRequest: TransactionRequest,
         transactionConsumer: TransactionConsumeProtocol = TransactionConsumeLoader(),
         addressLoader: AddressLoaderProtocol = AddressLoader(),
         settingLoader: SettingLoaderProtocol = SettingLoader()) {
        self.transactionRequest = transactionRequest
        self.transactionConsumer = transactionConsumer
        self.settingLoader = settingLoader
        self.addressLoader = addressLoader
        self.mintedToken = transactionRequest.mintedToken
        self.mintedTokenDisplay = transactionRequest.mintedToken.symbol
        if let amount = transactionRequest.amount {
            let am = BigUInt(amount).quotientAndRemainder(dividingBy: BigUInt(transactionRequest.mintedToken.subUnitToUnit))
            self.amountDisplay = "\(am.quotient).\(am.remainder)"
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
        self.loadAddresses(withGroup: loadingGroup)
        DispatchQueue.global().async {
            loadingGroup.wait()
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }

    func consumeTransactionRequest() {
        guard let mintedTokenId = self.mintedToken?.id else { return }

        guard let params = TransactionConsumptionParams(
            transactionRequest: self.transactionRequest,
            address: self.addressDisplay != "" ? self.addressDisplay : nil,
            mintedTokenId: mintedTokenId,
            amount: self.mintedToken?.formattedAmount(forAmount: self.amountDisplay),
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
        let formattedAmount = transactionConsumption.amount / transactionConsumption.mintedToken.subUnitToUnit
        if transactionConsumption.transactionRequest.type == .send {
            //swiftlint:disable:next line_length
            return "\("trequest_consumer.message.successfully".localized()) \("trequest_consumer.message.received".localized()) \(formattedAmount) \(transactionConsumption.mintedToken.symbol) \("trequest_consumer.message.from".localized()) \(transactionConsumption.transactionRequest.address)"
        } else {
            //swiftlint:disable:next line_length
            return "\("trequest_consumer.message.successfully".localized()) \("trequest_consumer.message.sent".localized()) \(formattedAmount) \(transactionConsumption.mintedToken.symbol) \("trequest_consumer.message.to".localized()) \(transactionConsumption.transactionRequest.address)"
        }
    }

    private func updateConsumeButtonState() {
        guard self.mintedToken != nil else {
            self.isConsumeButtonEnabled = false
            return
        }
        self.isConsumeButtonEnabled = true
    }

    private func loadAddresses(withGroup group: DispatchGroup?) {
        self.addressLoader.getAll { (result) in
            defer { group?.leave() }
            switch result {
            case .success(data: let addresses):
                self.addresses = addresses
                self.onSuccessGetAddresses?()
            case .fail(error: let error):
                self.handleOMGError(error)
                self.onFailedLoadAddress?(.omiseGO(error: error))
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

    func didUpdateExpirationDate(_ expirationDate: Date) {
        self.expirationDate = expirationDate
    }

    // MARK: Picker
    func didSelect(row: Int, picker: Picker) {
        switch picker {
        case .mintedToken: self.mintedToken = self.settings?.mintedTokens[row]
        case .address: self.address = self.addresses[row]
        }
    }

    func numberOfRows(inPicker picker: Picker) -> Int {
        switch picker {
        case .mintedToken: return self.settings?.mintedTokens.count ?? 0
        case .address: return self.addresses.count
        }
  
    }

    func numberOfColumnsInPicker() -> Int {
        return 1
    }

    func title(forRow row: Int, picker: Picker) -> String? {
        switch picker {
        case .mintedToken: return self.settings?.mintedTokens[row].name
        case .address: return self.addresses[row].address
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
    }

    func onFailedTransactionConsumptionFinalized(_ transactionConsumption: TransactionConsumption, error: OmiseGO.APIError) {
        self.onFailedConsume?(OMGShopError.omiseGO(error: OMGError.api(apiError: error)))
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
