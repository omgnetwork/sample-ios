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

    let title = "trequest_consumer.title".localized()
    let consumeButtonTitle = "trequest_consumer.button.title.consume".localized()

    let tokenLabel = "trequest_consumer.label.token".localized()
    let amountLabel = "trequest_consumer.label.amount".localized()
    let addressLabel = "trequest_consumer.label.address".localized()
    let correlationIdLabel = "trequest_consumer.label.correlation_id".localized()
    let expirationDateLabel = "trequest_consumer.label.expiration_date".localized()
    let nextButtonTitle = "trequest_consumer.button.title.next".localized()

    // Delegate closures
    var onLoadStateChange: ObjectClosure<Bool>?
    var onSuccessConsume: ObjectClosure<String>?
    var onFailedConsume: FailureClosure?
    var onSuccessGetSettings: SuccessClosure?
    var onFailedGetSettings: FailureClosure?
    var onConsumeButtonStateChange: ObjectClosure<Bool>?
    var onPendingConfirmation: ObjectClosure<String>?

    var mintedTokenDisplay: String
    var amountDisplay: String
    var addressDisplay: String
    var correlationIdDisplay: String
    var expirationDateDisplay: String

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

    private let settingLoader: SettingLoaderProtocol
    private let transactionRequest: TransactionRequest
    private var transactionConsumption: TransactionConsumption?
    private let idemPotencyToken = UUID().uuidString
    private let transactionConsumer: TransactionConsumeProtocol

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
    private var settings: Setting? {
        didSet {
            self.mintedToken = settings?.mintedTokens.first
        }
    }

    init(transactionRequest: TransactionRequest,
         transactionConsumer: TransactionConsumeProtocol = TransactionConsumeLoader(),
         settingLoader: SettingLoaderProtocol = SettingLoader()) {
        self.transactionRequest = transactionRequest
        self.transactionConsumer = transactionConsumer
        self.settingLoader = settingLoader
        self.mintedToken = transactionRequest.mintedToken
        self.mintedTokenDisplay = transactionRequest.mintedToken.symbol
        if let amount = transactionRequest.amount {
            let am = BigUInt(amount).quotientAndRemainder(dividingBy: BigUInt(transactionRequest.mintedToken.subUnitToUnit))
            self.amountDisplay = "\(am.quotient).\(am.remainder)"
        } else {
            self.amountDisplay = ""
        }
        self.addressDisplay = ""
        self.correlationIdDisplay = ""
        self.expirationDateDisplay = ""
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
            self.updateConsumeButtonState()
        }
    }

    func consumeTransactionRequest() {
        guard let mintedTokenId = self.mintedToken?.id else { return }

        guard let params = TransactionConsumptionParams(
            transactionRequest: self.transactionRequest,
            address: self.addressDisplay != "" ? self.addressDisplay : nil,
            mintedTokenId: mintedTokenId,
            amount: self.formattedAmount(),
            idempotencyToken: self.idemPotencyToken,
            correlationId: self.correlationIdDisplay != "" ? self.correlationIdDisplay : nil,
            expirationDate: self.expirationDate,
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
            return "\("trequest_consumer.message.successfully".localized()) \("trequest_consumer.message.received".localized()) \(formattedAmount) \(transactionConsumption.mintedToken.symbol) \("trequest_consumer.message.from".localized()) \(transactionConsumption.address)"
        } else {
            //swiftlint:disable:next line_length
            return "\("trequest_consumer.message.successfully".localized()) \("trequest_consumer.message.sent".localized()) \(formattedAmount) \(transactionConsumption.mintedToken.symbol) \("trequest_consumer.message.to".localized()) \(transactionConsumption.address)"
        }

    }

    private func formattedAmount() -> Double? {
        guard self.transactionRequest.allowAmountOverride,
            self.amountDisplay != "",
            let amount = Double(self.amountDisplay) else { return nil }
        let formattedAmount = self.transactionRequest.mintedToken.subUnitToUnit * amount
        return Double(formattedAmount)
    }

    private func updateConsumeButtonState() {
        guard self.mintedToken != nil else {
            self.isConsumeButtonEnabled = false
            return
        }
        self.isConsumeButtonEnabled = true
    }

    func stopListening() {
        self.transactionConsumption?.stopListening(withClient: SessionManager.shared.omiseGOSocketClient)
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

extension TRequestConsumerViewModel: TransactionConsumptionEventDelegate {

    func didReceiveTransactionConsumptionApproval(_ transactionConsumption: TransactionConsumption, forEvent event: SocketEvent) {
        self.onSuccessConsume?(
            self.successConsumeMessage(withTransacionConsumption: transactionConsumption)
        )
        self.stopListening()
    }

    func didReceiveTransactionConsumptionRejection(_ transactionConsumption: TransactionConsumption, forEvent event: SocketEvent) {
        self.onFailedConsume?(OMGShopError.message(message: "trequest_consumer.error.consumption_rejected"))
        self.stopListening()
    }

    func didStartListening() {
        print("Did start listening")
    }

    func didStopListening() {
        print("Did stop listening")
    }

    func didReceiveError(_ error: OMGError) {
        print("Did receive error: \(error.message)")
    }

}
