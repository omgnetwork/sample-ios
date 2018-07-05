//
//  SessionManager.swift
//  OMGShop
//
//  Created by Mederic Petit on 30/10/17.
//  Copyright © 2017-2018 Omise Go Pte. Ltd. All rights reserved.
//

import KeychainSwift
import OmiseGO

protocol SessionManagerProtocol {
    var currentUser: User? { get set }

    func login(withAppToken appAuthenticationToken: String, omiseGOAuthenticationToken: String, userId: String)
    func loadCurrentUser(withSuccessClosure success: @escaping SuccessClosure,
                         failure: @escaping (_ error: OMGError) -> Void)
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

    var omiseGOClient: HTTPClient!
    var omiseGOSocketClient: SocketClient!

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
        let httpConfig = ClientConfiguration(baseURL: Constant.omiseGOhostURL,
                                             apiKey: Constant.omiseGOAPIKey,
                                             authenticationToken: token,
                                             debugLog: true)
        self.omiseGOClient = HTTPClient(config: httpConfig)
        let socketConfig = ClientConfiguration(baseURL: Constant.omiseGOSocketURL,
                                               apiKey: Constant.omiseGOAPIKey,
                                               authenticationToken: token)
        self.omiseGOSocketClient = SocketClient(config: socketConfig, delegate: self)
    }

    // SessionManagerProtocol

    func login(withAppToken appAuthenticationToken: String, omiseGOAuthenticationToken: String, userId: String) {
        self.keychain.set(userId, forKey: UserDefaultKeys.userId.rawValue)
        self.keychain.set(appAuthenticationToken, forKey: UserDefaultKeys.appAuthenticationToken.rawValue)
        self.keychain.set(omiseGOAuthenticationToken, forKey: UserDefaultKeys.omiseGOAuthenticationToken.rawValue)
        self.loadTokens()
    }

    func loadCurrentUser(withSuccessClosure success: @escaping SuccessClosure,
                         failure: @escaping (_ error: OMGError) -> Void) {
        guard self.isLoggedIn() else {
            failure(.unexpected(message: "error.unexpected".localized()))
            return
        }
        User.getCurrent(using: self.omiseGOClient) { response in
            switch response {
            case let .success(data: user):
                self.currentUser = user
                success()
            case let .fail(error: error):
                failure(error)
            }
        }
    }

    func logout(withSuccessClosure success: @escaping SuccessClosure, failure: @escaping FailureClosure) {
        self.omiseGOClient.logout { response in
            switch response {
            case .success(data: _):
                self.clearTokens()
                success()
            case let .fail(error: error):
                failure(.omiseGO(error: error))
            }
        }
    }
}

extension SessionManager: SocketConnectionDelegate {
    func didConnect() {
        print("Socket did connect")
    }

    func didDisconnect(_: OMGError?) {
        print("Socket did disconnect")
    }
}
