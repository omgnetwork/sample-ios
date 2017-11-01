//
//  ProductListTests.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 24/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import XCTest
@testable import OMGShop

class ProductListTests: OMGShopTests {

    func testGetProducts() {
        let expectation = self.expectation(description: "get product list")
        let viewModel = ProductListViewModel()
        viewModel.reloadTableViewClosure = {
            defer { expectation.fulfill() }
            XCTAssertTrue(viewModel.numberOfCell() > 0)
        }
        viewModel.onFailLoadProducts = { XCTFail($0.localizedDescription) }
        viewModel.getProducts()
        waitForExpectations(timeout: 15.0, handler: nil)
    }

}
