//
//  ProductListViewController.swift
//  OMGShop
//
//  Created by Mederic Petit on 24/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit

class ProductListViewController: BaseViewController {

    let viewModel: ProductListViewModel = ProductListViewModel()

    @IBOutlet weak var tableView: UITableView!

    override func configureView() {
        super.configureView()
        self.title = self.viewModel.viewTitle
        self.tableView.registerNib(tableViewCell: ProductTableViewCell.self)
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        self.reloadProducts()
    }

    override func configureViewModel() {
        super.configureViewModel()
        self.viewModel.reloadTableViewClosure = {
            self.hideLoading()
            self.tableView.reloadData()
        }
    }

    private func reloadProducts() {
        self.showLoading()
        self.viewModel.getProducts()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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

extension ProductListViewController: ProductTableViewCellDelegate {

    func didTapBuy(forProduct product: Product) {
    }

}
