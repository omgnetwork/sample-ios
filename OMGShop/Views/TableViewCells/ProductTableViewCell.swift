//
//  ProductTableViewCell.swift
//  OMGShop
//
//  Created by Mederic Petit on 24/10/17.
//  Copyright © 2017-2018 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

protocol ProductTableViewCellDelegate: class {
    func didTapBuy(forProduct product: Product)
}

class ProductTableViewCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var buyButton: UIButton!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var productImageView: UIImageView!

    weak var delegate: ProductTableViewCellDelegate?

    var productCellViewModel: ProductCellViewModel! {
        didSet {
            self.nameLabel.text = productCellViewModel.name
            self.buyButton.setTitle(productCellViewModel.displayPrice, for: .normal)
            self.descriptionLabel.text = productCellViewModel.desc
            self.productImageView.downloaded(from: productCellViewModel.imageURL)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.buyButton.layer.borderColor = Color.omiseGOBlue.cgColor()
        self.buyButton.layer.borderWidth = 1
    }

    @IBAction func didTapBuyButton(_: UIButton) {
        self.delegate?.didTapBuy(forProduct: self.productCellViewModel.product)
    }
}
