//
//  SessionManager.swift
//  OMGShop
//
//  Created by Mederic Petit on 30/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import OmiseGO
import KeychainSwift

protocol SessionManagerProtocol {
    var currentUser: User? { get set }

    func login(withAppToken appAuthenticationToken: String, omiseGOAuthenticationToken: String, userId: String)
    func loadCurrentUser(withSuccessClosure success: @escaping SuccessClosure,
                         failure: @escaping (_ error: OmiseGOError) -> Void)
    func logout(withSuccessClosure success: @escaping SuccessClosure, failure: @escaping FailureClosure)
}

class SessionManager: SessionManagerProtocol {

    static let shared: SessionManager = SessionManager()

    init() {
        self.loadTokens()
    }

    let keychain = KeychainSwift()

    var currentUser: User?
    var customerId: String? // For the sake of simplicity we only store the customerId
    var authenticationToken: String?
    var omiseGOAuthenticationToken: String?
    var state: AppState {
        if self.isLoggedIn() {
            return self.currentUser == nil ? .loading : .login
        } else {
            return .logout
        }
    }

    func isLoggedIn() -> Bool {
        return self.authenticationToken != nil
    }

    func clearTokens() {
        self.keychain.delete(UserDefaultKeys.userId.rawValue)
        self.keychain.delete(UserDefaultKeys.appAuthenticationToken.rawValue)
        self.keychain.delete(UserDefaultKeys.omiseGOAuthenticationToken.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.selectedTokenSymbol.rawValue)
        self.authenticationToken = nil
        self.currentUser = nil
        self.omiseGOAuthenticationToken = nil
    }

    private func loadTokens() {
        self.customerId = self.keychain.get(UserDefaultKeys.userId.rawValue)
        self.authenticationToken = self.keychain.get(UserDefaultKeys.appAuthenticationToken.rawValue)
        self.omiseGOAuthenticationToken = self.keychain.get(UserDefaultKeys.omiseGOAuthenticationToken.rawValue)
        self.initializeOmiseGOSDK()
    }

    private func initializeOmiseGOSDK() {
        guard let token = self.omiseGOAuthenticationToken else { return }
        let config = OMGConfiguration(baseURL: Constant.omiseGOhostURL,
                                      apiKey: Constant.omiseGOAPIKey,
                                      authenticationToken: token)
        OMGClient.setup(withConfig: config)
    }

    // SessionManagerProtocol

    func login(withAppToken appAuthenticationToken: String, omiseGOAuthenticationToken: String, userId: String) {
        self.keychain.set(userId, forKey: UserDefaultKeys.userId.rawValue)
        self.keychain.set(appAuthenticationToken, forKey: UserDefaultKeys.appAuthenticationToken.rawValue)
        self.keychain.set(omiseGOAuthenticationToken, forKey: UserDefaultKeys.omiseGOAuthenticationToken.rawValue)
        self.loadTokens()
    }

    func loadCurrentUser(withSuccessClosure success: @escaping SuccessClosure,
                         failure: @escaping (_ error: OmiseGOError) -> Void) {
        guard self.isLoggedIn() else {
            failure(.unexpected(message: "error.unexpected".localized()))
            return
        }
        User.getCurrent { (response) in
            switch response {
            case .success(data: let user):
                self.currentUser = user
                success()
            case .fail(error: let error):
                failure(error)
            }
        }
    }

    func logout(withSuccessClosure success: @escaping SuccessClosure, failure: @escaping FailureClosure) {
        OMGClient.shared.logout { (response) in
            switch response {
            case .success(data: _):
                self.clearTokens()
                success()
            case .fail(error: let error):
                failure(.omiseGO(error: error))
            }
        }
    }
}
