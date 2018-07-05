//
//  TransactionConsumptionCellViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 3/7/18.
//  Copyright © 2017-2018 Omise Go Pte. Ltd. All rights reserved.
//

import BigInt
import OmiseGO

protocol TransactionConsumptionCellDelegate: class {
    func didTapApprove(withViewModel viewModel: TransactionConsumptionCellViewModel)
    func didTapReject(withViewModel viewModel: TransactionConsumptionCellViewModel)
}

class TransactionConsumptionCellViewModel: BaseViewModel {
    let transactionConsumption: TransactionConsumption!

    let direction: String
    let address: String
    let timeStamp: String
    let amount: String
    let color: UIColor
    let status: String
    var isActionable: Bool { return self.transactionConsumption.status == .pending }

    init(transactionConsumption: TransactionConsumption) {
        self.transactionConsumption = transactionConsumption
        var sign: String!
        switch transactionConsumption.transactionRequest.type {
        case .receive:
            self.direction = "transactions.label.from".localized()
            self.color = Color.transactionCreditGreen.uiColor()
            sign = "+"
        case .send:
            self.direction = "transactions.label.to".localized()
            self.color = Color.transactionDebitRed.uiColor()
            sign = "-"
        }
        var address = transactionConsumption.address
        if let user = transactionConsumption.user {
            address = address.appending(" (\(user.formattedUsername))")
        } else if let account = transactionConsumption.account {
            address = address.appending(" (\(account.name))")
        }
        self.address = address
        var statusText: String!
        switch transactionConsumption.status {
        case .approved: statusText = "qrcode_viewer.label.status.approved".localized()
        case .confirmed: statusText = "qrcode_viewer.label.status.confirmed".localized()
        case .expired: statusText = "qrcode_viewer.label.status.expired".localized()
        case .failed: statusText = "qrcode_viewer.label.status.failed".localized()
        case .pending: statusText = "qrcode_viewer.label.status.pending".localized()
        case .rejected: statusText = "qrcode_viewer.label.status.rejected".localized()
        }
        self.status = "- \(statusText!)"
        let displayableAmount = OMGNumberFormatter(precision: 5).string(from: transactionConsumption.estimatedRequestAmount,
                                                                        subunitToUnit: transactionConsumption.token.subUnitToUnit)
        amount = "\(sign!) \(displayableAmount) \(transactionConsumption.token.symbol)"
        timeStamp = transactionConsumption.createdAt.toString()
    }
}
