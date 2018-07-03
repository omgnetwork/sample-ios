//
//  TokenTableViewCell.swift
//  OMGShop
//
//  Created by Mederic Petit on 14/11/17.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

import UIKit

class TokenTableViewCell: UITableViewCell {
    @IBOutlet var symbolLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var checkmarkLabel: UILabel!

    var tokenCellViewModel: TokenCellViewModel! {
        didSet {
            self.symbolLabel.text = self.tokenCellViewModel.tokenSymbol
            self.amountLabel.text = self.tokenCellViewModel.tokenAmount
            self.checkmarkLabel.isHidden = !self.tokenCellViewModel.isSelected
        }
    }
}
