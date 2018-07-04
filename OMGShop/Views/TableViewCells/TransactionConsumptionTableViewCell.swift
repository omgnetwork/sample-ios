//
//  TransactionConsumptionTableViewCell.swift
//  OMGShop
//
//  Created by Mederic Petit on 3/7/18.
//  Copyright © 2018 Omise Go Ptd. Ltd. All rights reserved.
//

import UIKit

class TransactionConsumptionTableViewCell: UITableViewCell {
    @IBOutlet var directionLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var timestampLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var buttonView: UIView!

    weak var delegate: TransactionConsumptionCellDelegate?

    var viewModel: TransactionConsumptionCellViewModel! {
        didSet {
            self.directionLabel.text = self.viewModel.direction
            self.addressLabel.text = self.viewModel.address
            self.timestampLabel.text = self.viewModel.timeStamp
            self.amountLabel.text = self.viewModel.amount
            self.amountLabel.textColor = self.viewModel.color
            self.statusLabel.text = self.viewModel.status
            self.buttonView.isHidden = !self.viewModel.isActionable
        }
    }

    func setup(withViewModel viewModel: TransactionConsumptionCellViewModel,
               delegate: TransactionConsumptionCellDelegate?) {
        self.viewModel = viewModel
        self.delegate = delegate
    }

    @IBAction func didTapApproveButton(_: Any) {
        self.delegate?.didTapApprove(withViewModel: self.viewModel)
    }

    @IBAction func didTapRejectButton(_: Any) {
        self.delegate?.didTapReject(withViewModel: self.viewModel)
    }
}
