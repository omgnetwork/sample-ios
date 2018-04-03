//
//  Paginator.swift
//  OMGShop
//
//  Created by Mederic Petit on 5/3/18.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

import OmiseGO

enum LoadingState {
    case idle
    case loading
}

class Paginator<T: Decodable> {

    var page: Int = 1
    var perPage: Int = 10
    var state: LoadingState = .idle
    var reachedLastPage: Bool = false

    var successClosure: ObjectClosure<[T]>?
    var failureClosure: FailureClosure?

    var currentRequest: Request<JSONPaginatedListResponse<T>>?

    init(page: Int,
         perPage: Int,
         successClosure: ObjectClosure<[T]>?,
         failureClosure: FailureClosure?) {
        self.page = page
        self.perPage = perPage
        self.successClosure = successClosure
        self.failureClosure = failureClosure
    }

    func reset() {
        self.page = 1
        self.cancelLoading()
        self.reachedLastPage = false
    }

    func cancelLoading() {
        self.currentRequest?.cancel()
        self.state = .idle
    }

    func loadNext() {
        guard self.state == .idle && !self.reachedLastPage else { return }
        self.state = .loading
        self.load()
    }

    func load() {
        // Override in subclass
        assertionFailure("WARNING: Should not use directly this class. Subclass and override 'load()' instead!!")
    }

    func didReceiveResults(results: [T], pagination: Pagination) {
        self.updateNextPage(withPagination: pagination)
        self.successClosure?(results)
        self.state = .idle
    }

    func didFail(withError error: OMGError) {
        self.failureClosure?(.omiseGO(error: error))
        self.state = .idle
    }

    private func updateNextPage(withPagination pagination: Pagination) {
        self.page = pagination.currentPage + 1
        self.perPage = pagination.perPage
        self.reachedLastPage = pagination.isLastPage
    }

}
