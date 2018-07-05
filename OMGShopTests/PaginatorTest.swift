//
//  PaginatorTest.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 6/3/18.
//  Copyright © 2017-2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import OMGShop
@testable import OmiseGO
import XCTest

class PaginatorTest: XCTestCase {
    func testLoadSuccess() {
        var expectedTransactions: [Transaction] = []
        let successClosure: ObjectClosure<[Transaction]> = { transactions in
            expectedTransactions = transactions
        }
        let failureClosure: FailureClosure = { _ in
            XCTFail("Shouldn't fail")
        }
        let paginator = MockPaginator(page: 1,
                                      perPage: 10,
                                      successClosure: successClosure,
                                      failureClosure: failureClosure)
        paginator.success = true
        paginator.loadNext()
        XCTAssertFalse(expectedTransactions.isEmpty)
        XCTAssertEqual(paginator.page, 2)
        XCTAssertEqual(paginator.state, .idle)
    }

    func testLoadFailure() {
        var expectedError: OMGShopError?
        let successClosure: ObjectClosure<[Transaction]> = { _ in
            XCTFail("Shouldn't succeed")
        }
        let failureClosure: FailureClosure = { error in
            expectedError = error
        }
        let paginator = MockPaginator(page: 1,
                                      perPage: 10,
                                      successClosure: successClosure,
                                      failureClosure: failureClosure)
        paginator.success = false
        paginator.loadNext()
        XCTAssertNotNil(expectedError)
    }

    func testCancelRequest() {
        let paginator = Paginator<Transaction>(page: 1, perPage: 10, successClosure: nil, failureClosure: nil)
        let dummyClient = HTTPClient(config: ClientConfiguration(baseURL: "http://example.com",
                                                                 apiKey: "123",
                                                                 authenticationToken: "123"))
        let dummyEndpoint = APIEndpoint.custom(path: "", task: .requestPlain)
        let request = Request<JSONPaginatedListResponse<Transaction>>.init(client: dummyClient,
                                                                           endpoint: dummyEndpoint,
                                                                           callback: { _ in

        })
        paginator.currentRequest = try? request.start()
        XCTAssertEqual(request.task!.state, .running)
        paginator.cancelLoading()
        XCTAssertEqual(request.task!.state, .canceling)
    }
}
