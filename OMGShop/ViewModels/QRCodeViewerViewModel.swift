//
//  QRCodeViewerViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 14/2/18.
//  Copyright © 2017-2018 Omise Go Pte. Ltd. All rights reserved.
//

import BigInt
import OmiseGO
import UIKit

class QRCodeViewerViewModel: BaseViewModel {
    // Delegate closures
    var onSuccessApprove: ObjectClosure<String>?
    var onFailApprove: FailureClosure?
    var onSuccessReject: ObjectClosure<String>?
    var onFailReject: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?
    var onTableDataChange: EmptyClosure?

    let transactionRequest: TransactionRequest
    let consumptionRequestLabelTitle: String = "qrcode_viewer.label.consumption_requests".localized()
    var transactionConsumptionViewModels: [TransactionConsumptionCellViewModel] = [] {
        didSet {
            self.onTableDataChange?()
        }
    }

    var qrImage: UIImage? {
        return self.transactionRequest.qrImage()
    }

    var isLoading: Bool = false {
        didSet { self.onLoadStateChange?(isLoading) }
    }

    init(transactionRequest: TransactionRequest) {
        self.transactionRequest = transactionRequest
        super.init()
        transactionRequest.startListeningEvents(withClient: SessionManager.shared.omiseGOSocketClient, eventDelegate: self)
    }

    func rejectConsumption(forViewModel viewModel: TransactionConsumptionCellViewModel) {
        self.isLoading = true
        viewModel.transactionConsumption.reject(using: SessionManager.shared.omiseGOClient) { result in
            self.isLoading = false
            switch result {
            case .success: break
            case let .fail(error: error): self.onFailReject?(.omiseGO(error: error))
            }
        }
    }

    func approveConsumption(forViewModel viewModel: TransactionConsumptionCellViewModel) {
        self.isLoading = true
        viewModel.transactionConsumption.approve(using: SessionManager.shared.omiseGOClient) { result in
            self.isLoading = false
            switch result {
            case .success: break
            case let .fail(error: error): self.onFailApprove?(.omiseGO(error: error))
            }
        }
    }

    func numberOfRow() -> Int {
        return self.transactionConsumptionViewModels.count
    }

    func cellViewModel(forIndex index: Int) -> TransactionConsumptionCellViewModel {
        return self.transactionConsumptionViewModels[index]
    }

    func stopListening() {
        self.transactionRequest.stopListening(withClient: SessionManager.shared.omiseGOSocketClient)
    }

    private func successConsumeMessage(withTransacionConsumption transactionConsumption: TransactionConsumption) -> String {
        guard let amount = transactionConsumption.finalizedRequestAmount else {
            return "qrcode_viewer.error.transaction_failed".localized()
        }
        let formattedAmount = OMGNumberFormatter(precision: 5).string(from: amount,
                                                                      subunitToUnit: transactionConsumption.token.subUnitToUnit)
        if transactionConsumption.transactionRequest.type == .send {
            // swiftlint:disable:next line_length
            return "\("qrcode_viewer.message.successfully".localized()) \("qrcode_viewer.message.sent".localized()) \(formattedAmount) \(transactionConsumption.token.symbol) \("qrcode_viewer.message.to".localized()) \(transactionConsumption.address)"
        } else {
            // swiftlint:disable:next line_length
            return "\("qrcode_viewer.message.successfully".localized()) \("qrcode_viewer.message.received".localized()) \(formattedAmount) \(transactionConsumption.token.symbol) \("qrcode_viewer.message.from".localized()) \(transactionConsumption.address)"
        }
    }

    private func insertViewModel(forConsumption transactionConsumption: TransactionConsumption) {
        let viewModel = TransactionConsumptionCellViewModel(transactionConsumption: transactionConsumption)
        self.transactionConsumptionViewModels.insert(viewModel, at: 0)
    }

    private func updateViewModel(forConsumption transactionConsumption: TransactionConsumption) {
        if let viewModel = self.transactionConsumptionViewModels.filter({
            $0.transactionConsumption == transactionConsumption
        }).first, let index = self.transactionConsumptionViewModels.index(of: viewModel) {
            self.transactionConsumptionViewModels[index] = TransactionConsumptionCellViewModel(transactionConsumption:
                transactionConsumption)
        } else {
            self.insertViewModel(forConsumption: transactionConsumption)
        }
    }
}

extension QRCodeViewerViewModel: TransactionRequestEventDelegate {
    func onSuccessfulTransactionConsumptionFinalized(_ transactionConsumption: TransactionConsumption) {
        self.updateViewModel(forConsumption: transactionConsumption)
        switch transactionConsumption.status {
        case .confirmed: self.onSuccessApprove?(self.successConsumeMessage(withTransacionConsumption: transactionConsumption))
        case .rejected: self.onSuccessReject?("qrcode_viewer.message.successfully_rejected".localized())
        default: break
        }
    }

    func onFailedTransactionConsumptionFinalized(_ transactionConsumption: TransactionConsumption,
                                                 error: OmiseGO.APIError) {
        self.updateViewModel(forConsumption: transactionConsumption)
        self.onFailApprove?(.omiseGO(error: .api(apiError: error)))
    }

    func onTransactionConsumptionRequest(_ transactionConsumption: TransactionConsumption) {
        self.insertViewModel(forConsumption: transactionConsumption)
    }

    func didStartListening() {
        print("Start listening")
    }

    func didStopListening() {
        print("Stop listening")
    }

    func onError(_ error: OmiseGO.APIError) {
        print("received error: \(error.description)")
    }
}
