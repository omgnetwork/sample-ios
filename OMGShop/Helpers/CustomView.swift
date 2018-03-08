//
//  CustomView.swift
//  OMGShop
//
//  Created by Mederic Petit on 20/10/17.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

import SkyFloatingLabelTextField

class OMGFloatingTextField: SkyFloatingLabelTextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    private func setup() {

        self.textColor = Color.omiseGOBlue.uiColor()

        // Placeholder: The placeholder shown when there is no content in the text field
        self.placeholderFont = Font.avenirBook.withSize(15)
        self.placeholderColor = .lightGray

        // Line: The line shown below the text field
        self.selectedLineColor = Color.omiseGOBlue.uiColor()
        self.selectedLineHeight = 1
        self.lineColor = Color.omiseGOBlue.uiColor(withAlpha: 0.8)
        self.lineHeight = 1

        // Title: The label shown on top when there is content in the text field
        self.selectedTitleColor = .lightGray
        self.titleColor = .lightGray
        self.titleFont = Font.avenirBook.withSize(12)
        self.titleFormatter = { (text: String) -> String in
            return text
        }
    }

}
