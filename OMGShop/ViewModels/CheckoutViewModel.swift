//
//  CheckoutViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 24/10/17.
//  Copyright © 2017-2018 Omise Go Pte. Ltd. All rights reserved.
//

import BigInt
import OmiseGO

class CheckoutViewModel: BaseViewModel {
    // Delegate Closures
    var onDiscountPriceChange: ObjectClosure<String>?
    var onTotalPriceChange: ObjectClosure<String>?
    var onSuccessGetWallet: EmptyClosure?
    var onFailGetWallet: FailureClosure?
    var onSuccessPay: ObjectClosure<String>?
    var onFailPay: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?
    var onRedeemButtonStateChange: ObjectClosure<Bool>?
    var onRedeemButtonTitleChange: ObjectClosure<String>?

    let viewTitle: String = "checkout.view.title".localized()
    let yourProductLabel: String = "checkout.label.your_product".localized().uppercased()
    let subTotalLabel: String = "checkout.label.sub_total".localized()
    let discountLabel: String = "checkout.label.discount".localized()
    let totalLabel: String = "checkout.label.total".localized()
    let summaryLabel: String = "checkout.label.summary".localized().uppercased()
    let payButtonTitle: String = "checkout.button.title.pay".localized()

    let productName: String
    let productPrice: String
    let productImageURL: URL?

    let subTotalPrice: String
    var discountPrice: String = 0.0.displayablePrice() {
        didSet { self.onDiscountPriceChange?(discountPrice) }
    }

    var totalPrice: String = 0.0.displayablePrice() {
        didSet { self.onTotalPriceChange?(totalPrice) }
    }

    var isLoading: Bool = false {
        didSet { self.onLoadStateChange?(isLoading) }
    }

    var redeemButtonTitle: String = "checkout.button.title.redeem.loading".localized() {
        didSet { self.onRedeemButtonTitleChange?(redeemButtonTitle) }
    }

    var isRedeemButtonEnabled: Bool = false {
        didSet { self.onRedeemButtonStateChange?(isRedeemButtonEnabled) }
    }

    let checkout: Checkout!

    private let walletLoader: WalletLoaderProtocol
    private let productAPI: ProductAPIProtocol

    init(product: Product,
         walletLoader: WalletLoaderProtocol = WalletLoader(),
         productAPI: ProductAPIProtocol = ProductAPI()) {
        self.checkout = Checkout(product: product)
        self.productName = product.name
        self.productImageURL = URL(string: product.imageURL)
        self.productPrice = product.price.displayablePrice()
        self.subTotalPrice = product.price.displayablePrice()
        self.walletLoader = walletLoader
        self.productAPI = productAPI
        super.init()
        self.updatePrices()
    }

    func loadBalances() {
        self.isLoading = true
        self.walletLoader.getMain { result in
            self.isLoading = false
            switch result {
            case let .success(data: wallet):
                self.processWallet(wallet)
            case let .fail(error: error):
                self.handleOMGError(error)
                self.onFailGetWallet?(.omiseGO(error: error))
            }
            self.updateRedeemButtonTitle()
            self.isRedeemButtonEnabled = TokenManager.shared.selectedTokenSymbol != nil &&
                self.checkout.wallet != nil
        }
    }

    private func processWallet(_ wallet: Wallet) {
        TokenManager.shared.setDefaultTokenSymbolIfNotPresent(withBalances: wallet.balances)
        self.checkout.wallet = wallet
        self.checkout.selectedBalance =
            TokenManager.shared.selectedBalance(fromBalances: wallet.balances)
        self.onSuccessGetWallet?()
    }

    func updatePrices() {
        self.totalPrice = Double(self.checkout.total).displayablePrice()
        self.discountPrice = Double(self.checkout.discount).displayablePrice()
    }

    func pay() {
        self.isLoading = true
        let buyForm = BuyForm(tokenId: self.checkout.selectedBalance!.token.id,
                              tokenValue:
                              (self.checkout.redeemedToken *
                                  self.checkout.selectedBalance.token.subUnitToUnit / 100).description,
                              productId: self.checkout.product.uid)
        self.productAPI.buy(withForm: buyForm) { response in
            switch response {
            case .success(data: _):
                self.isLoading = false
                self.onSuccessPay?("\("checkout.message.pay_success".localized()) \(self.productName)")
            case let .fail(error: error):
                self.isLoading = false
                self.handleOMGShopError(error)
                self.onFailPay?(error)
            }
        }
    }

    private func updateRedeemButtonTitle() {
        if let selectedToken = TokenManager.shared.selectedTokenSymbol {
            self.redeemButtonTitle = "\("checkout.button.title.redeem.redeem".localized()) \(selectedToken)"
        } else {
            self.redeemButtonTitle = "checkout.button.title.redeem.no_balance".localized()
        }
    }
}
