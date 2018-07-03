//
//  TransactionCellViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 5/3/18.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

import OmiseGO
import BigInt

class TransactionCellViewModel: BaseViewModel {

    private let transaction: Transaction!

    let direction: String
    let address: String
    let timeStamp: String
    let amount: String
    let color: UIColor
    let status: String

    init(transaction: Transaction, currentUserAddress: String) {
        self.transaction = transaction
        var source: TransactionSource!
        var sign: String!
        if currentUserAddress == transaction.from.address {
            direction = "transactions.label.to".localized()
            address = transaction.to.address
            color = Color.transactionDebitRed.uiColor()
            source = transaction.from
            sign = "-"
        } else {
            direction = "transactions.label.from".localized()
            address = transaction.from.address
            color = Color.transactionCreditGreen.uiColor()
            source = transaction.to
            sign = "+"
        }
        var statusText: String!
        switch transaction.status {
        case .approved: statusText = "transactions.label.status.approved".localized()
        case .confirmed: statusText = "transactions.label.status.confirmed".localized()
        case .expired: statusText = "transactions.label.status.expired".localized()
        case .failed: statusText = "transactions.label.status.failed".localized()
        case .pending: statusText = "transactions.label.status.pending".localized()
        case .rejected: statusText = "transactions.label.status.rejected".localized()
        }
        self.status = "- \(statusText!)"
        let displayableAmount = OMGNumberFormatter(precision: 5).string(from: source.amount, subunitToUnit: source.token.subUnitToUnit)
        amount = "\(sign!) \(displayableAmount) \(source.token.symbol)"
        timeStamp = transaction.createdAt.toString()
    }

}
