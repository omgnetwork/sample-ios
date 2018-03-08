//
//  TransactionTableViewCell.swift
//  OMGShop
//
//  Created by Mederic Petit on 5/3/18.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {

    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!

    var transactionCellViewModel: TransactionCellViewModel! {
        didSet {
            self.directionLabel.text = transactionCellViewModel.direction
            self.addressLabel.text = transactionCellViewModel.address
            self.timestampLabel.text = transactionCellViewModel.timeStamp
            self.amountLabel.text = transactionCellViewModel.amount
            self.amountLabel.textColor = transactionCellViewModel.color
        }
    }

}
