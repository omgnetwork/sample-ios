//
//  ProfileViewModel.swift
//  OMGShop
//
//  Created by Mederic Petit on 1/11/17.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

import OmiseGO

class ProfileViewModel: BaseViewModel {
    // Delegate Closures
    var onFailGetWallet: FailureClosure?
    var onTableDataChange: SuccessClosure?
    var onLogoutSuccess: EmptyClosure?
    var onFailLogout: FailureClosure?
    var onSuccessReloadUser: ObjectClosure<String>?
    var onFailReloadUser: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?

    var name: String {
        guard let user = self.sessionManager.currentUser else { return "" }
        return user.formattedUsername
    }

    var isLoading: Bool = false {
        didSet { self.onLoadStateChange?(isLoading) }
    }

    var address: String?

    private var tokenCellViewModels: [TokenCellViewModel] = []

    let viewTitle = "profile.view.title".localized()
    let logoutButtonTitle = "profile.button.title.logout".localized()
    let closeButtonTitle = "profile.button.title.close".localized()
    let historyButtonTitle = "profile.button.title.history".localized()
    let token = "profile.label.token".localized()
    let amount = "profile.label.amount".localized()
    let selected = "profile.lable.selected".localized()

    private let sessionManager: SessionManagerProtocol
    private let walletLoader: WalletLoaderProtocol

    init(sessionManager: SessionManagerProtocol = SessionManager.shared,
         walletLoader: WalletLoaderProtocol = WalletLoader()) {
        self.sessionManager = sessionManager
        self.walletLoader = walletLoader
        super.init()
    }

    func loadData() {
        self.isLoading = true
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        self.sessionManager.loadCurrentUser(withSuccessClosure: {
            dispatchGroup.leave()
            self.onSuccessReloadUser?(self.name)
        }, failure: { error in
            dispatchGroup.leave()
            self.onFailReloadUser?(OMGShopError.omiseGO(error: error))
        })
        dispatchGroup.enter()
        self.walletLoader.getMain { result in
            self.isLoading = false
            switch result {
            case let .success(data: wallet):
                self.processWallet(wallet)
            case let .fail(error: error):
                self.handleOMGError(error)
                self.onFailGetWallet?(.omiseGO(error: error))
            }
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: DispatchQueue.main) {
            self.isLoading = false
        }
    }

    private func processWallet(_ wallet: Wallet) {
        TokenManager.shared.setDefaultTokenSymbolIfNotPresent(withBalances: wallet.balances)
        self.address = wallet.address
        self.generateTableViewModels(fromBalances: wallet.balances)
        self.onTableDataChange?()
    }

    func logout() {
        self.isLoading = true
        self.sessionManager.logout(withSuccessClosure: {
            dispatchMain {
                self.isLoading = false
                self.onLogoutSuccess?()
            }
        }, failure: { error in
            dispatchMain {
                self.isLoading = false
                self.onFailLogout?(error)
            }
        })
    }

    func numberOfRow() -> Int {
        return self.tokenCellViewModels.count
    }

    func cellViewModel(forIndex index: Int) -> TokenCellViewModel {
        return self.tokenCellViewModels[index]
    }

    func didSelectToken(atIndex index: Int) {
        let symbol = self.tokenCellViewModels[index].tokenSymbol
        TokenManager.shared.selectedTokenSymbol = symbol
        self.tokenCellViewModels.forEach({ $0.isSelected = $0.tokenSymbol == symbol })
        self.onTableDataChange?()
    }

    private func generateTableViewModels(fromBalances balances: [Balance]) {
        balances.forEach({
            let viewModel = TokenCellViewModel(balance: $0,
                                               isSelected: TokenManager.shared.isSelected($0.token))
            self.tokenCellViewModels.append(viewModel)
        })
    }
}
