//
//  StubGenerator.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 21/11/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//
// swiftlint:disable force_try

@testable import OMGShop
import OmiseGO

class StubGenerator {

    private func stub<T: Decodable>(forResource resource: String) -> T {
        let bundle = Bundle(for: StubGenerator.self)
        let directoryURL = bundle.url(forResource: "Fixtures", withExtension: nil)!
        let filePath = (resource as NSString).appendingPathExtension("json")! as String
        let fixtureFileURL = directoryURL.appendingPathComponent(filePath)
        let data = try! Data(contentsOf: fixtureFileURL)
        return try! JSONDecoder().decode(T.self, from: data)
    }

    func stubLogin() -> SessionToken { return self.stub(forResource: "login") }

    func stubCurrentUser() -> User { return self.stub(forResource: "current_user") }

    func stubProducts() -> [Product] { return self.stub(forResource: "product_list") }

    func mainAddress() -> Address { return self.stub(forResource: "address") }

    func pay() -> OMGShop.EmptyResponse { return self.stub(forResource: "pay") }

}
