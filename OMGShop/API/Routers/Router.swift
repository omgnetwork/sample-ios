//
//  Router.swift
//  OMGShop
//
//  Created by Mederic Petit on 30/10/17.
//  Copyright © 2017-2018 Omise Go Pte. Ltd. All rights reserved.
//

import Alamofire

enum Router<ResponseType: Decodable> {
    case login(withForm: LoginForm)
    case register(withForm: RegisterForm)
    case getProducts
    case buyProduct(withForm: BuyForm)

    @discardableResult
    func request(withCompletionClosure completionClosure: @escaping APIClosure<ResponseType>) -> URLSessionTask? {
        switch self {
        case .getProducts:
            let listClosure: APIClosure<JSONListResponse<ResponseType>> = { response in
                switch response {
                case let .success(data: data):
                    completionClosure(.success(data: data.data))
                case let .fail(error: error):
                    completionClosure(.fail(error: error))
                }
            }
            return APIController.request(withRouter: self, completionClosure: listClosure)
        default:
            return APIController.request(withRouter: self, completionClosure: completionClosure)
        }
    }
}

extension Router: URLRequestConvertible {
    var operation: String {
        switch self {
        case .login(withForm: _): return "/login"
        case .register(withForm: _): return "/signup"
        case .getProducts: return "products.get"
        case .buyProduct(withForm: _): return "product.buy"
        }
    }

    var body: Data? {
        switch self {
        case let .login(withForm: form): return form.encodedBody()
        case let .register(withForm: form): return form.encodedBody()
        case let .buyProduct(withForm: form): return form.encodedBody()
        default: return nil
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = try Constant.hostURL.asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(self.operation))
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        urlRequest.httpBody = self.body
        urlRequest.setValue(self.generateIdempotencyToken(), forHTTPHeaderField: "Idempotency-Token")
        return urlRequest
    }

    private func generateIdempotencyToken() -> String {
        return UUID().uuidString
    }
}
