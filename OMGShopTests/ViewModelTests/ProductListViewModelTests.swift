//
//  ProductListViewModelTests.swift
//  OMGShopTests
//
//  Created by Mederic Petit on 21/11/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import XCTest
@testable import OMGShop

class ProductListViewModelTests: XCTestCase {

    var mockProductAPI: MockProductAPI!
    var sut: ProductListViewModel!

    override func setUp() {
        super.setUp()
        self.mockProductAPI = MockProductAPI()
        self.sut = ProductListViewModel(productAPI: self.mockProductAPI)
    }

    override func tearDown() {
        self.mockProductAPI = nil
        self.sut = nil
        super.tearDown()
    }

    func testLoadProductsCalled() {
        self.sut.getProducts()
        XCTAssert(self.mockProductAPI.isLoadProductsCalled)
    }

    func testLoadProductsFailed() {
        var didFail = false
        self.sut.onFailLoadProducts = {
            XCTAssertEqual($0.message, "error")
            didFail = true
        }
        self.sut.getProducts()
        self.mockProductAPI.loadProductsFailed(withError: .init(code: .other("error"), description: "error"))
        XCTAssert(didFail)
    }

    func testLoadProductsSucceed() {
        var didCallReloadTableView = false
        self.sut.reloadTableViewClosure = { didCallReloadTableView = true }
        self.goToLoadProductsFinished()
        XCTAssert(didCallReloadTableView)
    }

    func testGetCellViewModel() {
        self.goToLoadProductsFinished()
        XCTAssert(self.sut.numberOfRow() == self.mockProductAPI.products.count)
        let indexPath = IndexPath(row: 0, section: 0)
        let cellViewModel = self.sut.productCellViewModel(at: indexPath)
        XCTAssertEqual(cellViewModel.name, self.mockProductAPI.products.first!.name)
    }

    func testCellViewModel() {
        let product = Product(uid: "1", name: "p1", description: "d1", imageURL: "http://example.com", price: 1.0)
        let cellViewModel = ProductCellViewModel(product: product)
        XCTAssertEqual(cellViewModel.name, "p1")
        XCTAssertEqual(cellViewModel.desc, "d1")
        XCTAssertEqual(cellViewModel.displayPrice, 1.0.displayablePrice())
        XCTAssertEqual(cellViewModel.imageURL, URL(string: "http://example.com"))
    }

    func testLoadingWhenRequesting() {
        var loadingStatus = false
        self.sut.onLoadStateChange = { loadingStatus = $0 }
        self.mockProductAPI.products = StubGenerator().stubProducts()
        self.sut.getProducts()
        XCTAssertTrue(loadingStatus)
        self.mockProductAPI.loadProductsSuccess()
        XCTAssertFalse(loadingStatus)
    }

}

extension ProductListViewModelTests {

    private func goToLoadProductsFinished() {
        self.mockProductAPI.products = StubGenerator().stubProducts()
        self.sut.getProducts()
        self.mockProductAPI.loadProductsSuccess()
    }

}
