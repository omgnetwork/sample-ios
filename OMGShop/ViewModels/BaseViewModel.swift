//
//  BaseViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 19/10/17.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

import OmiseGO

class BaseViewModel: NSObject {

    var onAppStateChange: EmptyClosure?

    func handleOMGShopError(_ error: OMGShopError) {
        switch error {
        case .api(error: let apiError) where apiError.isAuthorizationError():
            SessionManager.shared.clearTokens()
            self.onAppStateChange?()
        default: break
        }
    }

    func handleOMGError(_ error: OMGError) {
        switch error {
        case .api(apiError: let apiError) where apiError.isAuthorizationError():
            SessionManager.shared.clearTokens()
            self.onAppStateChange?()
        default: break
        }
    }

}
