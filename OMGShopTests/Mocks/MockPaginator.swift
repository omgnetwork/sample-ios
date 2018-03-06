//
//  MockPaginator.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 6/3/18.
//  Copyright © 2018 Mederic Petit. All rights reserved.
//

import UIKit
@testable import OMGShop
import OmiseGO

class MockPaginator: Paginator<Transaction> {

    var success: Bool = true

    override func load() {
        if self.success {
            self.didReceiveResults(results: StubGenerator.stubTransactions(),
                                   pagination: StubGenerator.stubPagination())
        } else {
            self.didFail(withError: .unexpected(message: "error"))
        }

    }

}
