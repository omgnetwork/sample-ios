//
//  BaseViewController.swift
//  OMGShop
//
//  Created by Mederic Petit on 19/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit
import Toaster

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }

    func configureView() {
        self.configureViewModel()
    }
    func configureViewModel() {}

}

extension BaseViewController {

    private func setupToast(_ toast: Toast) {
        toast.view.font = Font.avenirBook.withSize(15)
        toast.duration = Delay.long
    }

    func showMessage(_ message: String) {
        if let currentToast = ToastCenter.default.currentToast, currentToast.isExecuting {
            currentToast.cancel()
        }
        let messageToast = Toast(text: message)
        self.setupToast(messageToast)
        messageToast.show()
    }

    func showError(withMessage message: String) {
        if let currentToast = ToastCenter.default.currentToast, currentToast.isExecuting {
            currentToast.cancel()
        }
        let errorToast = Toast(text: message)
        self.setupToast(errorToast)
        errorToast.view.backgroundColor = UIColor.red
        errorToast.view.textColor = UIColor.white
        errorToast.show()
    }
}
