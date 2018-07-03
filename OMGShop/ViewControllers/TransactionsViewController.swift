//
//  TransactionsViewController.swift
//  OMGShop
//
//  Created by Mederic Petit on 5/3/18.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

import UIKit

class TransactionsViewController: BaseViewController {
    var viewModel: TransactionsViewModel!

    @IBOutlet var myAddressLabel: UILabel!
    @IBOutlet var myAddressValueLabel: UILabel!
    @IBOutlet var myAddressView: UIView!
    @IBOutlet var tableView: UITableView!
    var refreshControl: UIRefreshControl!

    lazy var loadingView: UIView = {
        let loader = UIActivityIndicatorView(activityIndicatorStyle: .white)
        loader.color = Color.omiseGOBlue.uiColor()
        loader.startAnimating()
        loader.translatesAutoresizingMaskIntoConstraints = false
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 44))
        view.addSubview(loader)
        [.centerX, .centerY].forEach({
            view.addConstraint(NSLayoutConstraint(item: loader,
                                                  attribute: $0,
                                                  relatedBy: .equal,
                                                  toItem: view,
                                                  attribute: $0,
                                                  multiplier: 1,
                                                  constant: 0))
        })
        return view
    }()

    override func configureView() {
        super.configureView()
        self.title = self.viewModel.viewTitle
        self.myAddressLabel.text = self.viewModel.myAddressLabel
        self.myAddressValueLabel.text = self.viewModel.myAddress
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = Color.omiseGOBlue.uiColor()
        self.refreshControl.addTarget(self, action: #selector(self.reloadTransactions), for: .valueChanged)
        self.tableView.registerNib(tableViewCell: TransactionTableViewCell.self)
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = 65
        self.tableView.refreshControl = self.refreshControl
        self.reloadTransactions()
        if #available(iOS 11.0, *) { self.tableView.contentInsetAdjustmentBehavior = .never }
    }

    override func configureViewModel() {
        super.configureViewModel()
        self.viewModel.onLoadStateChange = {
            self.tableView.tableFooterView = $0 ? self.loadingView : UIView()
        }
        self.viewModel.reloadTableViewClosure = {
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
        self.viewModel.onFailLoadTransactions = {
            self.showError(withMessage: $0.localizedDescription)
            self.refreshControl.endRefreshing()
        }
        self.viewModel.appendNewResultClosure = { indexPaths in
            UIView.setAnimationsEnabled(false)
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: indexPaths, with: UITableViewRowAnimation.none)
            self.tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.myAddressView.addDropShadow(withColor: .black,
                                         offset: CGSize(width: 0, height: 0),
                                         opacity: 0.5,
                                         radius: 2)
    }

    @objc private func reloadTransactions() {
        self.viewModel.reloadTransactions()
    }
}

extension TransactionsViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return self.viewModel.numberOfRow()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: TransactionTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: TransactionTableViewCell.identifier(),
            for: indexPath) as? TransactionTableViewCell else {
            return UITableViewCell()
        }
        cell.transactionCellViewModel = self.viewModel.transactionCellViewModel(at: indexPath)
        return cell
    }
}

extension TransactionsViewController: UITableViewDelegate {
    func tableView(_: UITableView, willDisplay _: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.viewModel.shouldLoadNext(atIndexPath: indexPath) {
            self.viewModel.getNextTransactions()
        }
    }
}
