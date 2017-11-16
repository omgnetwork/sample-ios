//
//  TokenTableViewCell.swift
//  OMGShop
//
//  Created by Mederic Petit on 14/11/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit

class TokenTableViewCell: UITableViewCell {

    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var checkmarkLabel: UILabel!

    var tokenCellViewModel: TokenCellViewModel! {
        didSet {
            self.symbolLabel.text = tokenCellViewModel.tokenSymbol
            self.amountLabel.text = tokenCellViewModel.tokenAmount
            self.checkmarkLabel.isHidden = !tokenCellViewModel.isSelected
        }
    }
}
