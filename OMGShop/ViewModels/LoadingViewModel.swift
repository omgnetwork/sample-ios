//
//  LoadingViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 30/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit
import OmiseGO

class LoadingViewModel: BaseViewModel {

    var onFailedLoading: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?
    var onAppStateChanged: EmptyClosure?

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
            self?.onAppStateChanged?()
            }, failure: { [weak self] (error) in
                switch error {
                case .api(apiError: let apiError) where apiError.isAuthorizationError():
                    SessionManager.shared.clearTokens()
                    self?.onAppStateChanged?()
                default: break
                }
                self?.isLoading = false
                self?.onFailedLoading?(OMGError.omiseGOError(error: error))
        })
    }

}
