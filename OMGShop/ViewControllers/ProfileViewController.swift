//
//  ProfileViewController.swift
//  OMGShop
//
//  Created by Mederic Petit on 1/11/17.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

import UIKit

class ProfileViewController: BaseViewController {
    let historySegueIdentifier = "showHistoryViewController"

    let viewModel: ProfileViewModel = ProfileViewModel()

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var tokenLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var selectedLabel: UILabel!
    @IBOutlet var logoutButton: UIButton!
    @IBOutlet var closeButton: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var historyButton: UIBarButtonItem!

    override func configureView() {
        super.configureView()
        self.title = self.viewModel.viewTitle
        self.nameLabel.text = self.viewModel.name
        self.tokenLabel.text = self.viewModel.token
        self.amountLabel.text = self.viewModel.amount
        self.selectedLabel.text = self.viewModel.selected
        self.logoutButton.setTitle(self.viewModel.logoutButtonTitle, for: .normal)
        self.closeButton.title = self.viewModel.closeButtonTitle
        self.historyButton.title = self.viewModel.historyButtonTitle
        self.tableView.registerNib(tableViewCell: TokenTableViewCell.self)
        self.tableView.tableFooterView = UIView()
        self.viewModel.loadData()
    }

    override func configureViewModel() {
        super.configureViewModel()
        self.viewModel.onTableDataChange = { self.tableView.reloadData() }
        self.viewModel.onFailGetWallet = { self.showError(withMessage: $0.localizedDescription) }
        self.viewModel.onLoadStateChange = { $0 ? self.showLoading() : self.hideLoading() }
        self.viewModel.onLogoutSuccess = {
            self.dismiss(animated: false, completion: nil)
            (UIApplication.shared.delegate as? AppDelegate)?.loadRootView()
        }
        self.viewModel.onFailLogout = { self.showError(withMessage: $0.localizedDescription) }
        self.viewModel.onSuccessReloadUser = { self.nameLabel.text = $0 }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.historySegueIdentifier,
            let vc: TransactionsViewController = segue.destination as? TransactionsViewController,
            let address: String = sender as? String {
            let viewModel: TransactionsViewModel = TransactionsViewModel(address: address)
            vc.viewModel = viewModel
        }
    }
}

extension ProfileViewController {
    @IBAction func tapCloseButton(_: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func tapLogoutButton(_: UIButton) {
        self.viewModel.logout()
    }

    @IBAction func tapHistoryButton(_: UIBarButtonItem) {
        guard let address = self.viewModel.address else { return }
        self.performSegue(withIdentifier: self.historySegueIdentifier, sender: address)
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return self.viewModel.numberOfRow()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: TokenTableViewCell =
            tableView.dequeueReusableCell(withIdentifier: TokenTableViewCell.identifier(),
                                          for: indexPath) as? TokenTableViewCell else {
            return UITableViewCell()
        }
        cell.tokenCellViewModel = self.viewModel.cellViewModel(forIndex: indexPath.row)
        return cell
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.didSelectToken(atIndex: indexPath.row)
    }
}
