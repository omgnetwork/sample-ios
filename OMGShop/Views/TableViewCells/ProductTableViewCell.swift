//
//  ProductTableViewCell.swift
//  OMGShop
//
//  Created by Mederic Petit on 24/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit

protocol ProductTableViewCellDelegate: class {
    func didTapBuy(forProduct product: Product)
}

class ProductTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!

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

    @IBAction func didTapBuyButton(_ sender: UIButton) {
        self.delegate?.didTapBuy(forProduct: self.productCellViewModel.product)
    }

}
