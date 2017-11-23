//
//  Router.swift
//  OMGShop
//
//  Created by Mederic Petit on 30/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
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
            let listClosure: APIClosure<JSONListResponse<ResponseType>> = { (response) in
                switch response {
                case .success(data: let data):
                    completionClosure(.success(data: data.data))
                case .fail(error: let error):
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
        case .login(withForm: let form): return form.encodedBody()
        case .register(withForm: let form): return form.encodedBody()
        case .buyProduct(withForm: let form): return form.encodedBody()
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
