//
//  OmiseGOWrapper.swift
//  OMGShop
//
//  Created by Mederic Petit on 21/11/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import OmiseGO

protocol AddressLoaderProtocol {
    func getMain(withCallback callback: @escaping Address.RetrieveRequestCallback)
}

/// This wrapper has been created for the sake of testing with dependency injection
class AddressLoader: AddressLoaderProtocol {

    func getMain(withCallback callback: @escaping Address.RetrieveRequestCallback) {
        Address.getMain(using: SessionManager.shared.omiseGOClient, callback: callback)
    }

}

protocol SettingLoaderProtocol {
    func get(withCallback callback: @escaping Setting.RetrieveRequestCallback)
}

/// This wrapper has been created for the sake of testing with dependency injection
class SettingLoader: SettingLoaderProtocol {

    func get(withCallback callback: @escaping Setting.RetrieveRequestCallback) {
        Setting.get(using: SessionManager.shared.omiseGOClient, callback: callback)
    }

}
