//
//  APIController.swift
//  OMGShop
//
//  Created by Mederic Petit on 30/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import Alamofire

class APIController {

    static let apiVersion = "1"
    static let shared = APIController()
    private let manager = Alamofire.SessionManager.default

    init() {
        self.manager.retrier = OMGRequestRetrier()
        self.manager.adapter = OMGRequestAdapter()
    }

    @discardableResult
    class func request<T: Decodable>(withRouter router: URLRequestConvertible,
                                     completionClosure: @escaping APIClosure<T>) -> URLSessionTask? {
        let request = self.shared.manager.request(router).responseData { (data) in
            if let response = data.response, [200, 500].contains(response.statusCode) {
                switch data.result {
                case .success(let data):
                    do {
                        let jsonDecoder = JSONDecoder()
                        let response: JSONResponse<T> = try jsonDecoder.decode(JSONResponse<T>.self, from: data)
                        completionClosure(response.data)
                    } catch let error {
                        completionClosure(.fail(error: .other(error: error)))
                    }
                case .failure(let error):
                    completionClosure(.fail(error: .other(error: error)))
                }
            } else {
                completionClosure(.fail(error: OMGError.unexpected))
            }
        }
        debugPrint(request)
        return request.task
    }

}

private class OMGRequestRetrier: RequestRetrier {

    func should(_ manager: Alamofire.SessionManager,
                retry request: Alamofire.Request,
                with error: Error,
                completion: @escaping Alamofire.RequestRetryCompletion) {
        guard request.retryCount < 3 else {
            completion(false, 0.0)
            return
        }
        completion(true, 0.0)
    }

}

private class OMGRequestAdapter: RequestAdapter {

    enum AuthenticationType {

        case authenticated(token: String, userId: String)
        case unAuthenticated

        var encodedKey: String? {
            var key: String!
            switch self {
            case .authenticated(token: let authenticationToken, userId: let userId):
                key = "\(Constant.apiKeyId):\(Constant.apiKey):\(userId):\(authenticationToken)"
            case .unAuthenticated:
                key = "\(Constant.apiKeyId):\(Constant.apiKey)"
            }
            return key.data(using: .utf8, allowLossyConversion: false)?.base64EncodedString()
        }

        func encodedAuthorizationHeader() -> String? {
            guard let encodedKey = self.encodedKey else { return nil }
            return "\(Constant.authenticationScheme) \(encodedKey)"
        }
    }

    var authenticationType: AuthenticationType {
        if let authenticationToken = SessionManager.shared.authenticationToken,
            let customerId = SessionManager.shared.customerId {
            return .authenticated(token: authenticationToken, userId: customerId)
        }
        return .unAuthenticated
    }

    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var request = urlRequest
        request.setValue(self.contentTypeHeader(), forHTTPHeaderField: "Accept")
        request.setValue(self.contentTypeHeader(), forHTTPHeaderField: "Content-Type")
        if let authorizationHeader = self.authenticationType.encodedAuthorizationHeader() {
            request.setValue(authorizationHeader, forHTTPHeaderField: "Authorization")
        }
        return request
    }

    private func contentTypeHeader() -> String {
        return "application/vnd.omisego.v\(APIController.apiVersion)+json"
    }

}
