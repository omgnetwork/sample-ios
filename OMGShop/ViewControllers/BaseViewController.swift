//
//  BaseViewController.swift
//  OMGShop
//
//  Created by Mederic Petit on 19/10/17.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

import Toaster
import MBProgressHUD

class BaseViewController: UIViewController {

    var loading: MBProgressHUD?

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

    func showLoading() {
        self.loading = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.loading!.contentColor = Color.omiseGOBlue.uiColor()
        self.loading!.bezelView.style = .solidColor
        self.loading!.bezelView.color = UIColor.white
        self.loading!.mode = .indeterminate
    }

    func hideLoading() {
        if let loading = self.loading {
            loading.hide(animated: true)
        }
    }

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
