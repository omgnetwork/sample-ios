//
//  CheckoutViewController.swift
//  OMGShop
//
//  Created by Mederic Petit on 24/10/17.
//  Copyright © 2017-2018 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

class CheckoutViewController: BaseViewController {
    var viewModel: CheckoutViewModel!

    @IBOutlet var yourProductLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var productPriceLabel: UILabel!
    @IBOutlet var summaryLabel: UILabel!
    @IBOutlet var subTotalLabel: UILabel!
    @IBOutlet var subTotalPriceLabel: UILabel!
    @IBOutlet var discountLabel: UILabel!
    @IBOutlet var discountPriceLabel: UILabel!
    @IBOutlet var totalLabel: UILabel!
    @IBOutlet var totalPriceLabel: UILabel!
    @IBOutlet var redeemButton: UIButton!
    @IBOutlet var payButton: UIButton!

    override func configureView() {
        super.configureView()
        self.title = self.viewModel.viewTitle
        self.yourProductLabel.text = self.viewModel.yourProductLabel
        self.nameLabel.text = self.viewModel.productName
        self.imageView.downloaded(from: self.viewModel.productImageURL)
        self.productPriceLabel.text = self.viewModel.productPrice
        self.summaryLabel.text = self.viewModel.summaryLabel
        self.subTotalLabel.text = self.viewModel.subTotalLabel
        self.subTotalPriceLabel.text = self.viewModel.subTotalPrice
        self.discountLabel.text = self.viewModel.discountLabel
        self.discountPriceLabel.text = self.viewModel.discountPrice
        self.totalLabel.text = self.viewModel.totalLabel
        self.totalPriceLabel.text = self.viewModel.totalPrice
        self.redeemButton.setTitle(self.viewModel.redeemButtonTitle, for: .normal)
        self.redeemButton.isEnabled = self.viewModel.isRedeemButtonEnabled
        self.payButton.setTitle(self.viewModel.payButtonTitle, for: .normal)
        self.payButton.isEnabled = self.viewModel.isRedeemButtonEnabled

        self.viewModel.loadBalances()
    }

    override func configureViewModel() {
        super.configureViewModel()
        self.viewModel.onLoadStateChange = { $0 ? self.showLoading() : self.hideLoading() }
        self.viewModel.onFailGetWallet = { self.showError(withMessage: $0.localizedDescription) }
        self.viewModel.onDiscountPriceChange = { self.discountPriceLabel.text = $0 }
        self.viewModel.onTotalPriceChange = { self.totalPriceLabel.text = $0 }
        self.viewModel.onSuccessPay = { message in
            self.showMessage(message)
            self.navigationController?.popViewController(animated: true)
        }
        self.viewModel.onFailPay = { self.showError(withMessage: $0.localizedDescription) }
        self.viewModel.onAppStateChange = { (UIApplication.shared.delegate as? AppDelegate)?.loadRootView() }
        self.viewModel.onRedeemButtonTitleChange = { self.redeemButton.setTitle($0, for: .normal) }
        self.viewModel.onRedeemButtonStateChange = {
            self.redeemButton.isEnabled = $0
            self.payButton.isEnabled = $0
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.redeemButton.layer.borderColor = Color.omiseGOBlue.cgColor()
        self.redeemButton.layer.borderWidth = 1
    }
}

extension CheckoutViewController {
    @IBAction func didTapRedeemButton(_: UIButton) {
        RedeemPopupViewController.present(fromViewController: self, checkout: self.viewModel.checkout, delegate: self)
    }

    @IBAction func didTapPayButton(_: UIButton) {
        self.viewModel.pay()
    }
}

extension CheckoutViewController: RedeemPopupViewControllerDelegate {
    func didFinishToRedeem() {
        self.viewModel.updatePrices()
    }
}
