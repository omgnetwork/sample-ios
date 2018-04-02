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
    var onFailGetAddress: FailureClosure?
    var onTableDataChange: SuccessClosure?
    var onLogoutSuccess: EmptyClosure?
    var onFailLogout: FailureClosure?
    var onSuccessReloadUser: ObjectClosure<String>?
    var onFailReloadUser: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?

    var name: String {
        guard let user = self.sessionManager.currentUser else { return "" }
        return user.username
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
    private let addressLoader: AddressLoaderProtocol

    init(sessionManager: SessionManagerProtocol = SessionManager.shared,
         addressLoader: AddressLoaderProtocol = AddressLoader()) {
        self.sessionManager = sessionManager
        self.addressLoader = addressLoader
        super.init()
    }

    func loadData() {
        self.isLoading = true
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        self.sessionManager.loadCurrentUser(withSuccessClosure: {
            dispatchGroup.leave()
            self.onSuccessReloadUser?(self.name)
        }, failure: { (error) in
            dispatchGroup.leave()
            self.onFailReloadUser?(OMGShopError.omiseGO(error: error))
        })
        dispatchGroup.enter()
        self.addressLoader.getMain { (result) in
            self.isLoading = false
            switch result {
            case .success(data: let address):
                self.processAddress(address)
            case .fail(error: let error):
                self.handleOMGError(error)
                self.onFailGetAddress?(.omiseGO(error: error))
            }
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: DispatchQueue.main) {
            self.isLoading = false
        }
    }

    private func processAddress(_ address: Address) {
        MintedTokenManager.shared.setDefaultTokenSymbolIfNotPresent(withBalances: address.balances)
        self.address = address.address
        self.generateTableViewModels(fromBalances: address.balances)
        self.onTableDataChange?()
    }

    func logout() {
        self.isLoading = true
        self.sessionManager.logout(withSuccessClosure: {
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

    func numberOfRow() -> Int {
        return self.tokenCellViewModels.count
    }

    func cellViewModel(forIndex index: Int) -> TokenCellViewModel {
        return self.tokenCellViewModels[index]
    }

    func didSelectToken(atIndex index: Int) {
        let symbol = self.tokenCellViewModels[index].tokenSymbol
        MintedTokenManager.shared.selectedTokenSymbol = symbol
        self.tokenCellViewModels.forEach({ $0.isSelected = $0.tokenSymbol == symbol })
        self.onTableDataChange?()
    }

    private func generateTableViewModels(fromBalances balances: [Balance]) {
        balances.forEach({
            let viewModel = TokenCellViewModel(balance: $0,
                                               isSelected: MintedTokenManager.shared.isSelected($0.mintedToken))
            self.tokenCellViewModels.append(viewModel)
        })
    }

}
