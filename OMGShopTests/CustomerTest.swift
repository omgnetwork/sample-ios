//
//  CustomerTest.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 31/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import XCTest
@testable import OMGShop

class CustomerTest: OMGShopTests {

    func testGetCustomer() {
        let expectation = self.expectation(description: "Get current customer")
        CustomerAPI.getCurrent { (response) in
            defer { expectation.fulfill() }
            switch response {
            case .success(data: let customer):
                XCTAssert(customer.email != "")
            case .fail(error: let error):
                XCTFail(error.localizedDescription)
            }
        }
        waitForExpectations(timeout: 15, handler: nil)
    }

}
