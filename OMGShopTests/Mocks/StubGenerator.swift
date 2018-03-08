//
//  StubGenerator.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 21/11/17.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//
// swiftlint:disable force_try

@testable import OMGShop
@testable import OmiseGO

class StubGenerator {

    class private func stub<T: Decodable>(forResource resource: String) -> T {
        let bundle = Bundle(for: StubGenerator.self)
        let directoryURL = bundle.url(forResource: "Fixtures", withExtension: nil)!
        let filePath = (resource as NSString).appendingPathExtension("json")! as String
        let fixtureFileURL = directoryURL.appendingPathComponent(filePath)
        let data = try! Data(contentsOf: fixtureFileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom({return try dateDecodingStrategy(decoder: $0)})
        return try! decoder.decode(T.self, from: data)
    }

    class func stubLogin() -> SessionToken { return self.stub(forResource: "login") }

    class func stubCurrentUser() -> User { return self.stub(forResource: "current_user") }

    class func stubProducts() -> [Product] { return self.stub(forResource: "product_list") }

    class func mainAddress() -> Address { return self.stub(forResource: "address") }

    class func pay() -> OMGShop.EmptyResponse { return self.stub(forResource: "pay") }

    class func settings() -> Setting { return self.stub(forResource: "settings") }

    class func transactionRequest() -> TransactionRequest { return self.stub(forResource: "transaction_request") }

    class func transactionConsume() -> TransactionConsume { return self.stub(forResource: "transaction_consume")}

    class func stubTransactions() -> [Transaction] { return self.stub(forResource: "transactions")}

    class func stubPagination() -> Pagination { return self.stub(forResource: "pagination")}

}
