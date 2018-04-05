//
//  QRCodeViewerViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 14/2/18.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

import UIKit
import OmiseGO
import BigInt

class QRCodeViewerViewModel: BaseViewModel {

    // Delegate closures
    var onConsumptionRequest: SuccessClosure?
    var onSuccessApprove: ObjectClosure<String>?
    var onFailApprove: FailureClosure?
    var onSuccessReject: ObjectClosure<String>?
    var onFailReject: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?

    let transactionRequest: TransactionRequest
    var transactionConsumption: TransactionConsumption?
    var qrImage: UIImage? {
        return self.transactionRequest.qrImage()
    }

    var isLoading: Bool = false {
        didSet { self.onLoadStateChange?(isLoading) }
    }

    let waitingLabel = "qrcode_viewer.label.waiting".localized()
    let consumptionRequestTitle = "qrcode_viewer.alert.consumption_request.title".localized()
    let approveButtonTitle = "qrcode_viewer.alert.consumption_request.approve".localized()
    let rejectButtonTitle = "qrcode_viewer.alert.consumption_request.reject".localized()

    init(transactionRequest: TransactionRequest) {
        self.transactionRequest = transactionRequest
        super.init()
        transactionRequest.startListeningEvents(withClient: SessionManager.shared.omiseGOSocketClient, eventDelegate: self)
    }

    func consumptionRequestMessage() -> String {
        guard let tc = self.transactionConsumption else { return "" }
        //swiftlint:disable:next line_length
        return "\(tc.address) \("qrcode_viewer.alert.consumption_request.wants_to".localized()) \(self.transactionRequest.type == .send ? "qrcode_viewer.alert.consumption_request.take_you".localized() : "qrcode_viewer.alert.consumption_request.send_you".localized()) \(self.displayableAmount()) \(tc.mintedToken.symbol), \("qrcode_viewer.alert.consumption_request.do_you_approve".localized())"
    }

    private func displayableAmount() -> String {
        guard let tc = self.transactionConsumption else { return "" }
        let am = BigUInt(tc.amount).quotientAndRemainder(dividingBy: BigUInt(tc.mintedToken.subUnitToUnit))
        return "\(am.quotient).\(am.remainder)"
    }

    func reject() {
        guard let tc = self.transactionConsumption else { return }
        self.isLoading = true
        tc.reject(using: SessionManager.shared.omiseGOClient) { (result) in
            self.isLoading = false
            switch result {
            case .success: break
            case .fail(error: let error): self.onFailReject?(.omiseGO(error: error))
            }
        }
    }

    func approve() {
        guard let tc = self.transactionConsumption else { return }
        self.isLoading = true
        tc.approve(using: SessionManager.shared.omiseGOClient) { (result) in
            self.isLoading = false
            switch result {
            case .success: break
            case .fail(error: let error): self.onFailApprove?(.omiseGO(error: error))
            }
        }
    }

    func stopListening() {
        self.transactionRequest.stopListening(withClient: SessionManager.shared.omiseGOSocketClient)
    }
}

extension QRCodeViewerViewModel: TransactionRequestEventDelegate {

    func didReceiveTransactionConsumptionApproval(_ transactionConsumption: TransactionConsumption, forEvent event: SocketEvent) {
        self.onSuccessApprove?("qrcode_viewer.message.successfully_approved".localized())
    }

    func didReceiveTransactionConsumptionRejection(_ transactionConsumption: TransactionConsumption, forEvent event: SocketEvent) {
        self.onSuccessReject?("qrcode_viewer.message.successfully_rejected".localized())
    }

    func didReceiveTransactionConsumptionRequest(_ transactionConsumption: TransactionConsumption, forEvent event: SocketEvent) {
        self.transactionConsumption = transactionConsumption
        self.onConsumptionRequest?()
    }

    func didStartListening() {
        print("Start listening")
    }

    func didStopListening() {
        print("Stop listening")
    }

    func didReceiveError(_ error: OMGError) {
        print("received error: \(error.message)")
    }

}
