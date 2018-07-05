//
//  BaseViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 19/10/17.
//  Copyright © 2017-2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

class BaseViewModel: NSObject {
    var onAppStateChange: EmptyClosure?

    func handleOMGShopError(_ error: OMGShopError) {
        switch error {
        case let .api(error: apiError) where apiError.isAuthorizationError():
            SessionManager.shared.clearTokens()
            self.onAppStateChange?()
        default: break
        }
    }

    func handleOMGError(_ error: OMGError) {
        switch error {
        case let .api(apiError: apiError) where apiError.isAuthorizationError():
            SessionManager.shared.clearTokens()
            self.onAppStateChange?()
        default: break
        }
    }
}
