//
//  ProfileViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 1/11/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit
import OmiseGO

class ProfileViewModel: BaseViewModel {

    // Delegate Closures
    var onFailGetBalances: FailureClosure?
    var onSuccessGetBalances: SuccessClosure?
    var onLoadStateChanged: ObjectClosure<Bool>?
    var onLogoutSuccess: EmptyClosure?
    var onFailLogout: FailureClosure?

    var name: String {
        guard let user = SessionManager.shared.currentCustomer else { return "" }
        return user.fullName()
    }
    var isLoading: Bool = false {
        didSet { self.onLoadStateChanged?(isLoading) }
    }
    var tokenSymbol: String = ""
    var tokenAmount: String = ""

    let viewTitle = "profile.view.title".localized()
    let logoutButtonTitle = "profile.button.title.logout".localized()
    let closeButtonTitle = "profile.button.title.close".localized()
    let token = "profile.label.token".localized()
    let amount = "profile.label.amount".localized()
    
    override init() {
        super.init()
    }

    func loadBalances() {
        let decoder = JSONDecoder()
        //swiftlint:disable:next line_length
        let balanceJSON = "{\r\n  \"object\": \"balance\",\r\n  \"minted_token\": {\r\n    \"object\": \"minted_token\",\r\n    \"symbol\": \"OMG\",\r\n    \"name\": \"OmiseGO\",\r\n    \"subunit_to_unit\": 100\r\n  },\r\n  \"address\": \"my_omg_address\",\r\n  \"amount\": 800000\r\n}".data(using: .utf8)
        if let balance = try? decoder.decode(Balance.self, from: balanceJSON!) {
            self.tokenSymbol = balance.mintedToken.symbol
            self.tokenAmount = balance.displayAmount(withPrecision: 2)
        }
        self.onSuccessGetBalances?()
        // TODO: For later
        //        Balance.getAll { (result) in
        //            self.isLoading = false
        //            switch result {
        //            case .success(data: let balances):
        //                self.checkout.balance = balances.first
        //                self.onSuccessGetBalances?()
        //            case .fail(error: let error):
        //                switch error {
        //                case .api(apiError: let apiError) where !apiError.isAuthorizationError():
        //                    SessionManager.shared.clearTokens()
        //                    self.onAppStateChanged?()
        //                default: break
        //                }
        //                self.onFailGetBalances?(.omiseGOError(error: error))
        //            }
        //        }
    }

    func logout() {
        self.isLoading = true
        SessionManager.shared.logout(withSuccessClosure: {
            dispatchMain {
                self.isLoading = false
                self.onLogoutSuccess?()
            }
        }, failure: { (error) in
            dispatchMain {
                self.isLoading = false
                self.onFailLogout?(error)
            }
        })
    }

}
