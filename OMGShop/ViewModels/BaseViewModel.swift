//
//  BaseViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 19/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import OmiseGO

class BaseViewModel: NSObject {

    var onAppStateChange: EmptyClosure?

    func handleOMGShopError(_ error: OMGError) {
        switch error {
        case .api(error: let apiError) where apiError.isAuthorizationError():
            SessionManager.shared.clearTokens()
            self.onAppStateChange?()
        default: break
        }
    }

    func handleOmiseGOrror(_ error: OmiseGOError) {
        switch error {
        case .api(apiError: let apiError) where apiError.isAuthorizationError():
            SessionManager.shared.clearTokens()
            self.onAppStateChange?()
        default: break
        }
    }

}
