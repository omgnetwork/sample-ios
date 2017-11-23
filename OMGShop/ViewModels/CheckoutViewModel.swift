//
//  CheckoutViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 24/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import OmiseGO

class CheckoutViewModel: BaseViewModel {

    // Delegate Closures
    var onDiscountPriceChange: ObjectClosure<String>?
    var onTotalPriceChange: ObjectClosure<String>?
    var onSuccessGetAddress: EmptyClosure?
    var onFailGetAddress: FailureClosure?
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

    private let addressLoader: AddressLoaderProtocol
    private let productAPI: ProductAPIProtocol

    init(product: Product,
         addressLoader: AddressLoaderProtocol = AddressLoader(),
         productAPI: ProductAPIProtocol = ProductAPI()) {
        self.checkout = Checkout(product: product)
        self.productName = product.name
        self.productImageURL = URL(string: product.imageURL)
        self.productPrice = product.displayPrice
        self.subTotalPrice = product.displayPrice
        self.addressLoader = addressLoader
        self.productAPI = productAPI
        super.init()
        self.updatePrices()
    }

    func loadBalances() {
        self.isLoading = true
        self.addressLoader.getMain { (result) in
            self.isLoading = false
            switch result {
            case .success(data: let address):
                self.processAddress(address)
            case .fail(error: let error):
                self.handleOmiseGOrror(error)
                self.onFailGetAddress?(.omiseGO(error: error))
            }
            self.updateRedeemButtonTitle()
            self.isRedeemButtonEnabled = MintedTokenManager.shared.selectedTokenSymbol != nil
        }
    }

    private func processAddress(_ address: Address) {
        MintedTokenManager.shared.setDefaultTokenSymbolIfNotPresent(withBalances: address.balances)
        self.checkout.address = address
        self.checkout.selectedBalance =
            MintedTokenManager.shared.selectedBalance(fromBalances: address.balances)
        self.onSuccessGetAddress?()
    }

    func updatePrices() {
        self.totalPrice = self.checkout.total.displayablePrice()
        self.discountPrice = self.checkout.selectedBalance?.mintedToken.display(forAmount: self.checkout.discount) ??
            0.0.displayablePrice()
    }

    func pay() {
        self.isLoading = true
        let buyForm = BuyForm(tokenId: self.checkout.selectedBalance!.mintedToken.id,
                              tokenValue: self.checkout.redeemedToken,
                              productId: self.checkout.product.uid)
        self.productAPI.buy(withForm: buyForm) { (response) in
            switch response {
            case .success(data: _):
                self.isLoading = false
                self.onSuccessPay?("\("checkout.message.pay_success".localized()) \(self.productName)")
            case .fail(error: let error):
                self.isLoading = false
                self.handleOMGShopError(error)
                self.onFailPay?(error)
            }
        }
    }

    private func updateRedeemButtonTitle() {
        if let selectedToken = MintedTokenManager.shared.selectedTokenSymbol {
            self.redeemButtonTitle = "\("checkout.button.title.redeem.redeem".localized()) \(selectedToken)"
        } else {
            self.redeemButtonTitle = "checkout.button.title.redeem.no_balance".localized()
        }
    }

}
