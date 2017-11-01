//
//  LoadingViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 30/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit

class LoadingViewModel: BaseViewModel {

    var onSuccessLoading: SuccessClosure?
    var onFailedLoading: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?

    let retryButtonTitle: String = "loading.button.title.retry".localized()

    var isLoading: Bool = true {
        didSet {
            self.onLoadStateChange?(isLoading)
        }
    }

    func load() {
        self.isLoading = true
        SessionManager.shared.loadCurrentUser(withSuccessClosure: { [weak self] in
            self?.isLoading = false
            self?.onSuccessLoading?()
        }, failure: { [weak self] (error) in
            self?.isLoading = false
            self?.onFailedLoading?(error)
        })
    }

}
