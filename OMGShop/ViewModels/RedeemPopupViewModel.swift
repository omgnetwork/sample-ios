//
//  RedeemPopupViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 25/10/17.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

import OmiseGO
import BigInt

class RedeemPopupViewModel: BaseViewModel {

    // Delegate Closures
    var onRedeemTokenUpdate: ObjectClosure<String>?
    var onDiscountUpdate: ObjectClosure<String>?

    var title: String {
        //swiftlint:disable:next line_length
        return "\("popup.redeem.label.title.redeem".localized()) \(self.checkout.selectedBalance.token.symbol) \("popup.redeem.label.title.coins".localized())"
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

    private var selectedTokenAmount: BigUInt = 0 {
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
        self.selectedTokenAmount = BigUInt(value)
        self.buildGetDiscountString()
        self.buildRedeemTokenString()
    }

    func maximumSliderValue() -> Float {
        let amount = (BigUInt(self.checkout.selectedBalance.amount) /
            BigUInt(self.checkout.selectedBalance.token.subUnitToUnit)) * 100
        return Float(min(amount, self.checkout.subTotal))
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
        let tokens = NSAttributedString(string: " \(amount) \(self.checkout.selectedBalance.token.symbol) ",
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
        let amount = self.selectedTokenAmount / 100
        let displayableAmount = formatter.string(from: NSNumber(value: Double(amount))) ?? "-"
        self.redeemToken =
        "\("popup.redeem.redeem".localized()) \(displayableAmount) \(self.checkout.selectedBalance.token.symbol)"
    }

    private func buildGetDiscountString() {
        let displayAmount = self.selectedTokenAmount
        self.getDiscount = "\("popup.redeem.get_discount".localized()) \(Double(displayAmount).displayablePrice())"
    }

}
