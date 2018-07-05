//
//  QRCodeViewerViewController.swift
//  OMGShop
//
//  Created by Mederic Petit on 13/2/18.
//  Copyright © 2017-2018 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

class QRCodeViewerViewController: BaseViewController {
    var viewModel: QRCodeViewerViewModel!
    @IBOutlet var qrImageView: UIImageView!
    @IBOutlet var transactionsTableView: UITableView!
    @IBOutlet var consumptionRequestsLabel: UILabel!

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.viewModel.stopListening()
    }

    override func configureView() {
        super.configureView()
        self.transactionsTableView.registerNib(tableViewCell: TransactionConsumptionTableViewCell.self)
        self.qrImageView.image = self.viewModel.transactionRequest.qrImage()
        self.transactionsTableView.tableFooterView = UIView()
        self.transactionsTableView.rowHeight = 82
        self.consumptionRequestsLabel.text = self.viewModel.consumptionRequestLabelTitle
    }

    override func configureViewModel() {
        super.configureViewModel()
        self.viewModel.onFailApprove = { self.showError(withMessage: $0.message) }
        self.viewModel.onFailReject = { self.showError(withMessage: $0.message) }
        self.viewModel.onSuccessApprove = { self.showMessage($0) }
        self.viewModel.onSuccessReject = { self.showMessage($0) }
        self.viewModel.onTableDataChange = { self.transactionsTableView.reloadData() }
        self.viewModel.onLoadStateChange = { $0 ? self.showLoading() : self.hideLoading() }
    }
}

extension QRCodeViewerViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt _: IndexPath) {
    }
}

extension QRCodeViewerViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return self.viewModel.numberOfRow()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: TransactionConsumptionTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: TransactionConsumptionTableViewCell.identifier(),
            for: indexPath) as? TransactionConsumptionTableViewCell else {
            return UITableViewCell()
        }
        cell.setup(withViewModel: self.viewModel.cellViewModel(forIndex: indexPath.row), delegate: self)
        return cell
    }
}

extension QRCodeViewerViewController: TransactionConsumptionCellDelegate {
    func didTapApprove(withViewModel viewModel: TransactionConsumptionCellViewModel) {
        self.viewModel.approveConsumption(forViewModel: viewModel)
    }

    func didTapReject(withViewModel viewModel: TransactionConsumptionCellViewModel) {
        self.viewModel.rejectConsumption(forViewModel: viewModel)
    }
}
