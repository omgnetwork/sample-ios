//
//  TransactionCellViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 5/3/18.
//  Copyright © 2018 Mederic Petit. All rights reserved.
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

    init(transaction: Transaction, currentUserAddress: String) {
        self.transaction = transaction
        if currentUserAddress == transaction.from.address {
            direction = "transactions.label.to".localized()
            address = transaction.to.address
            color = Color.transactionDebit.uiColor()
            let calculatedAmount = BigUInt(transaction.from.amount).quotientAndRemainder(
                dividingBy: BigUInt(transaction.from.mintedToken.subUnitToUnit))
            let displayableAmount = "\(calculatedAmount.quotient).\(calculatedAmount.remainder)"
            amount = "- \(displayableAmount) \(transaction.to.mintedToken.symbol)"
        } else {
            direction = "transactions.label.from".localized()
            address = transaction.from.address
            color = Color.transactionCredit.uiColor()
            let calculatedAmount =
                BigUInt(transaction.to.amount).quotientAndRemainder(
                    dividingBy: BigUInt(transaction.to.mintedToken.subUnitToUnit))
            let displayableAmount = "\(calculatedAmount.quotient).\(calculatedAmount.remainder)"
            amount = "+ \(displayableAmount) \(transaction.to.mintedToken.symbol)"
        }
        timeStamp = transaction.createdAt.toString()
    }

}
