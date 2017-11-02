//
//  ProductListViewController.swift
//  OMGShop
//
//  Created by Mederic Petit on 24/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit

class ProductListViewController: BaseViewController {

    let showCheckoutViewControllerSegueIdentifer = "showCheckoutViewController"

    let viewModel: ProductListViewModel = ProductListViewModel()

    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!

    override func configureView() {
        super.configureView()
        self.title = self.viewModel.viewTitle
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = Color.omiseGOBlue.uiColor()
        self.refreshControl.addTarget(self, action: #selector(reloadProducts), for: .valueChanged)
        self.tableView.registerNib(tableViewCell: ProductTableViewCell.self)
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        self.tableView.refreshControl = self.refreshControl
        self.reloadProducts()
        if #available(iOS 11.0, *) { self.tableView.contentInsetAdjustmentBehavior = .never }
    }

    override func configureViewModel() {
        super.configureViewModel()
        self.viewModel.onLoadStateChanged = { $0 ? self.showLoading() : self.hideLoading()}
        self.viewModel.reloadTableViewClosure = {
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
        self.viewModel.onFailLoadProducts = { self.showError(withMessage: $0.localizedDescription) }
    }

    @objc private func reloadProducts() {
        self.viewModel.getProducts()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.showCheckoutViewControllerSegueIdentifer,
            let vc: CheckoutViewController = segue.destination as? CheckoutViewController,
            let product: Product = sender as? Product {
            let viewModel: CheckoutViewModel = CheckoutViewModel(product: product)
            vc.viewModel = viewModel
        }
    }
}

extension ProductListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfCell()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: ProductTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: ProductTableViewCell.identifier(),
            for: indexPath) as? ProductTableViewCell else {
            return UITableViewCell()
        }
        cell.productCellViewModel = self.viewModel.productCellViewModel(at: indexPath)
        cell.delegate = self
        return cell
    }

}

extension ProductListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = self.viewModel.productCellViewModel(at: indexPath).product
        self.performSegue(withIdentifier: self.showCheckoutViewControllerSegueIdentifer, sender: product)
    }

}

extension ProductListViewController: ProductTableViewCellDelegate {

    func didTapBuy(forProduct product: Product) {
        self.performSegue(withIdentifier: self.showCheckoutViewControllerSegueIdentifer, sender: product)
    }

}
