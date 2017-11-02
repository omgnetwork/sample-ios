//
//  ProfileViewController.swift
//  OMGShop
//
//  Created by Mederic Petit on 1/11/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit

class ProfileViewController: BaseViewController {

    let viewModel: ProfileViewModel = ProfileViewModel()

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tokenLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var tokenSymbolLabel: UILabel!
    @IBOutlet weak var tokenAmountLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var closeButton: UIBarButtonItem!

    override func configureView() {
        super.configureView()
        self.title = self.viewModel.viewTitle
        self.nameLabel.text = self.viewModel.name
        self.tokenLabel.text = self.viewModel.token
        self.amountLabel.text = self.viewModel.amount
        self.tokenSymbolLabel.text = self.viewModel.tokenSymbol
        self.tokenAmountLabel.text = self.viewModel.tokenAmount
        self.logoutButton.setTitle(self.viewModel.logoutButtonTitle, for: .normal)
        self.closeButton.title = self.viewModel.closeButtonTitle.localized()
        self.viewModel.loadBalances()
    }

    override func configureViewModel() {
        super.configureViewModel()
        self.viewModel.onSuccessGetBalances = {
            self.tokenSymbolLabel.text = self.viewModel.tokenSymbol
            self.tokenAmountLabel.text = self.viewModel.tokenAmount
        }
        self.viewModel.onFailGetBalances = { self.showError(withMessage: $0.localizedDescription) }
        self.viewModel.onLoadStateChanged = { $0 ? self.showLoading() : self.hideLoading() }
        self.viewModel.onLogoutSuccess = {
            self.dismiss(animated: false, completion: nil)
            (UIApplication.shared.delegate as? AppDelegate)?.loadRootView()
        }
        self.viewModel.onFailLogout = { self.showError(withMessage: $0.localizedDescription) }
    }

}

extension ProfileViewController {

    @IBAction func tapCloseButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func tapLogoutButton(_ sender: UIButton) {
        self.viewModel.logout()
    }

}
