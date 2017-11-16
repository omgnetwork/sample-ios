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

    let retryButtonTitle: String = "loading.button.title.retry".localized()

    var isLoading: Bool = true {
        didSet {
            self.onLoadStateChange?(isLoading)
        }
    }

    func load() {
        self.isLoading = true
        SessionManager.shared.loadCurrentUser(withSuccessClosure: {
            self.isLoading = false
            self.onAppStateChange?()
            }, failure: { (error) in
                self.handleOmiseGOrror(error)
                self.isLoading = false
                self.onFailedLoading?(OMGError.omiseGO(error: error))
        })
    }

}
