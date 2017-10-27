//
//  RedeemPopupViewController.swift
//  OMGShop
//
//  Created by Mederic Petit on 25/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit

protocol RedeemPopupViewControllerDelegate: class {
    func didFinishToRedeem()
}

class RedeemPopupViewController: BaseViewController {

    var viewModel: RedeemPopupViewModel!

    weak var delegate: RedeemPopupViewControllerDelegate?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var totalTokenToRedeemLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var redeemTokenLabel: UILabel!
    @IBOutlet weak var getDiscountLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var redeemButton: UIButton!

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.cancelButton.layer.borderColor = Color.omiseGOBlue.cgColor()
        self.cancelButton.layer.borderWidth = 1
    }

    override func configureView() {
        super.configureView()
        self.titleLabel.text = self.viewModel.title
        self.totalTokenToRedeemLabel.attributedText = self.viewModel.totalTokenToRedeem
        self.redeemTokenLabel.text = self.viewModel.redeemToken
        self.getDiscountLabel.text = self.viewModel.getDiscount
        self.cancelButton.setTitle(self.viewModel.cancelButtonTitle, for: .normal)
        self.redeemButton.setTitle(self.viewModel.redeemButtonTitle, for: .normal)
        self.slider.minimumValue = 0
        self.slider.maximumValue = self.viewModel.maximumSliderValue()
        self.slider.value = self.viewModel.initialSliderValue()
    }

    override func configureViewModel() {
        super.configureViewModel()
        self.viewModel.onRedeemTokenUpdate = { self.redeemTokenLabel.text = $0 }
        self.viewModel.onDiscountUpdate = { self.getDiscountLabel.text = $0 }
    }

    class func present(fromViewController viewController: UIViewController,
                       checkout: Checkout,
                       delegate: RedeemPopupViewControllerDelegate) {
        guard let popup: RedeemPopupViewController =
            RedeemPopupViewController.newInstance(fromStoryboard: .popup) as? RedeemPopupViewController else {
            return
        }
        popup.viewModel = RedeemPopupViewModel(checkout: checkout)
        popup.delegate = delegate
        viewController.present(popup, animated: true, completion: nil)
    }

}

extension RedeemPopupViewController {

    @IBAction func didUpdateSliderValue(_ sender: UISlider) {
        let step: Float = 5000
        var roundedValue: Float = 0
        let maximumValue = sender.maximumValue
        let currentValue = sender.value
        if step >= maximumValue && currentValue > maximumValue / 2 {
            roundedValue = maximumValue
        } else if currentValue == maximumValue {
            roundedValue = maximumValue
        } else {
            roundedValue = min(round(currentValue / step) * step, maximumValue)
        }
        sender.value = roundedValue
        self.viewModel.updateRedeem(withSliderValue: roundedValue)
    }

    @IBAction func didTapCancelButton(_ sender: UIButton) {
        self.dismiss()
    }

    @IBAction func didTapRedeemButton(_ sender: UIButton) {
        self.viewModel.redeem()
        self.dismiss()
    }

    private func dismiss() {
        self.delegate?.didFinishToRedeem()
        self.dismiss(animated: true, completion: nil)
    }

}
