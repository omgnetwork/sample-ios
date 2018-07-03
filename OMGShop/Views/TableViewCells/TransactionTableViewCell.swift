//
//  TransactionTableViewCell.swift
//  OMGShop
//
//  Created by Mederic Petit on 5/3/18.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    @IBOutlet var directionLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var timestampLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!

    var transactionCellViewModel: TransactionCellViewModel! {
        didSet {
            self.directionLabel.text = self.transactionCellViewModel.direction
            self.addressLabel.text = self.transactionCellViewModel.address
            self.timestampLabel.text = self.transactionCellViewModel.timeStamp
            self.amountLabel.text = self.transactionCellViewModel.amount
            self.amountLabel.textColor = self.transactionCellViewModel.color
            self.statusLabel.text = self.transactionCellViewModel.status
        }
    }
}
