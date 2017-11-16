//
//  RedeemPopupViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 25/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit
import OmiseGO

class RedeemPopupViewModel: BaseViewModel {

    // Delegate Closures
    var onRedeemTokenUpdate: ObjectClosure<String>?
    var onDiscountUpdate: ObjectClosure<String>?

    var title: String {
        //swiftlint:disable:next line_length
        return "\("popup.redeem.label.title.redeem".localized()) \(self.checkout.selectedBalance.mintedToken.symbol) \("popup.redeem.label.title.coins".localized())"
    }
    let cancelButtonTitle: String = "popup.redeem.button.title.cancel".localized()
    let redeemButtonTitle: String = "popup.redeem.button.title.redeem".localized()
    private let checkout: Checkout

    var totalTokenToRedeem: NSAttributedString!
    var redeemToken: String! {
        didSet { self.onRedeemTokenUpdate?(redeemToken) }
    }
    var getDiscount: String! {
        didSet { self.onDiscountUpdate?(getDiscount) }
    }

    private var selectedTokenAmount: Double = 0 {
        didSet { self.buildRedeemTokenString() }
    }

    init(checkout: Checkout) {
        self.checkout = checkout
        super.init()
        self.selectedTokenAmount = checkout.redeemedToken
        self.buildTotalTokenAttributedString()
        self.buildRedeemTokenString()
        self.buildGetDiscountString()
    }

    func updateRedeem(withSliderValue value: Float) {
        self.selectedTokenAmount = Double(value)
        self.buildGetDiscountString()
        self.buildRedeemTokenString()
    }

    func maximumSliderValue() -> Float {
        return Float(min(self.checkout.selectedBalance.amount / OMGShopManager.shared.setting.tokenValue,
                         self.checkout.subTotal / OMGShopManager.shared.setting.tokenValue))
    }

    func initialSliderValue() -> Float {
        return Float(self.selectedTokenAmount)
    }

    func redeem() {
        self.checkout.redeemedToken = self.selectedTokenAmount
    }

    private func buildTotalTokenAttributedString() {
        let baseAttributes: [NSAttributedStringKey: Any] = [.font: Font.avenirBook.withSize(14)]
        let youHave = NSAttributedString(string: "popup.redeem.you_have".localized(), attributes: baseAttributes)
        let toRedeem = NSAttributedString(string: "popup.redeem.to_redeem".localized(), attributes: baseAttributes)
        let tokensAttributes: [NSAttributedStringKey: Any] = [.font: Font.avenirMedium.withSize(14)]
        let amount = self.checkout.selectedBalance.displayAmount(withPrecision: 2)
        let tokens = NSAttributedString(string: " \(amount) \(self.checkout.selectedBalance.mintedToken.symbol) ",
            attributes: tokensAttributes)
        let mutableAS = NSMutableAttributedString()
        mutableAS.append(youHave)
        mutableAS.append(tokens)
        mutableAS.append(toRedeem)
        self.totalTokenToRedeem = mutableAS
    }

    private func buildRedeemTokenString() {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        let amount = self.selectedTokenAmount / self.checkout.selectedBalance.mintedToken.subUnitToUnit
        let displayableAmount = formatter.string(from: NSNumber(value: amount)) ?? "-"
        self.redeemToken =
        "\("popup.redeem.redeem".localized()) \(displayableAmount) \(self.checkout.selectedBalance.mintedToken.symbol)"
    }

    private func buildGetDiscountString() {
        let displayAmount = self.checkout.selectedBalance.mintedToken.display(forAmount: self.selectedTokenAmount)
        self.getDiscount = "\("popup.redeem.get_discount".localized()) \(displayAmount)"
    }

}
