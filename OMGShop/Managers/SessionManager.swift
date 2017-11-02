//
//  SessionManager.swift
//  OMGShop
//
//  Created by Mederic Petit on 30/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit
import OmiseGO
import KeychainSwift

class SessionManager {

    static let shared: SessionManager = SessionManager()

    init() {
        self.loadTokens()
    }

    let keychain = KeychainSwift()

    var currentCustomer: Customer?
    var authenticationToken: String?
    var omiseGOAuthenticationToken: String?
    var state: AppState {
        if self.isLoggedIn() {
            return self.currentCustomer == nil ? .loading : .login
        } else {
            return .logout
        }
    }

    func isLoggedIn() -> Bool {
        return self.authenticationToken != nil
    }

    func login(withAppToken appAuthenticationToken: String, omiseGOAuthenticationToken: String) {
        self.keychain.set(appAuthenticationToken, forKey: UserDefaultKeys.appAuthenticationToken.rawValue)
        self.keychain.set(omiseGOAuthenticationToken, forKey: UserDefaultKeys.omiseGOAuthenticationToken.rawValue)
        self.loadTokens()
    }

    func clearTokens() {
        self.keychain.delete(UserDefaultKeys.appAuthenticationToken.rawValue)
        self.keychain.delete(UserDefaultKeys.omiseGOAuthenticationToken.rawValue)
        self.authenticationToken = nil
        self.currentCustomer = nil
        self.omiseGOAuthenticationToken = nil
    }

    func logout(withSuccessClosure success: @escaping SuccessClosure, failure: @escaping FailureClosure) {
        OMGClient.shared.logout { (response) in
            //TODO: Uncomment this
            //            switch response {
            //            case .success(data: _):
            self.clearTokens()
            success()
            //            case .fail(error: let error):
            //                failure(.omiseGOError(error: error))
            //            }
        }

    }

    func loadCurrentUser(withSuccessClosure success: @escaping SuccessClosure, failure: @escaping FailureClosure) {
        guard self.isLoggedIn() else {
            failure(.unexpected)
            return
        }
        CustomerAPI.getCurrent { (response) in
            switch response {
            case .success(data: let customer):
                self.currentCustomer = customer
                success()
            case .fail(error: let error):
                failure(error)
            }
        }
    }

    private func loadTokens() {
        self.authenticationToken = self.keychain.get(UserDefaultKeys.appAuthenticationToken.rawValue)
        self.omiseGOAuthenticationToken = self.keychain.get(UserDefaultKeys.omiseGOAuthenticationToken.rawValue)
        self.initializeOmiseGOSDK()
    }

    private func initializeOmiseGOSDK() {
        guard let token = self.omiseGOAuthenticationToken else { return }
        let config = OMGConfiguration(baseURL: "https://kubera.omisego.io", apiKey: "", authenticationToken: token)
        OMGClient.setup(withConfig: config)
    }
}
