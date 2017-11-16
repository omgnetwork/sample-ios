//
//  LoadingViewController.swift
//  OMGShop
//
//  Created by Mederic Petit on 30/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit

class LoadingViewController: BaseViewController {

    let viewModel: LoadingViewModel = LoadingViewModel()

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var retryButton: UIButton!

    override func configureView() {
        super.configureView()
        self.retryButton.isHidden = self.viewModel.isLoading
        self.activityIndicator.isHidden = !self.viewModel.isLoading
        self.retryButton.setTitle(self.viewModel.retryButtonTitle, for: .normal)
        self.load()
    }

    override func configureViewModel() {
        super.configureViewModel()
        self.viewModel.onAppStateChange = { (UIApplication.shared.delegate as? AppDelegate)?.loadRootView() }
        self.viewModel.onFailedLoading = { self.showError(withMessage: $0.localizedDescription) }
        self.viewModel.onLoadStateChange = { (isLoading) in
            self.retryButton.isHidden = isLoading
            self.activityIndicator.isHidden = !isLoading
        }
    }

    @objc func load() {
        self.viewModel.load()
    }

}

extension LoadingViewController {

    @IBAction func tapRetryButton(_ sender: UIButton) {
        self.load()
    }

}
