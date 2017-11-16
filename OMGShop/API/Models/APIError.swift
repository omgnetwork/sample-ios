//
//  APIError.swift
//  OMGShop
//
//  Created by Mederic Petit on 30/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit

public struct APIError: CustomDebugStringConvertible {

    public let code: APIErrorCode
    public let description: String

    public var debugDescription: String {
        return "Error: \(code.debugDescription) - \(description)"
    }

    func isAuthorizationError() -> Bool {
        switch self.code {
        case .invalidAuthenticationToken: return true
        default: return false
        }
    }

    public enum APIErrorCode: CustomDebugStringConvertible, Decodable {

        case invalidAuthenticationToken
        case other(String)

        init(code: String) {
            switch code {
            case "user:invalid_authentication_token":
                self = .invalidAuthenticationToken
            case let code:
                self = .other(code)
            }
        }

        public init(from decoder: Decoder) throws {
            self.init(code: try decoder.singleValueContainer().decode(String.self))
        }

        public var code: String {
            switch self {
            case .invalidAuthenticationToken:
                return "user:invalid_authentication_token"
            case .other(let code):
                return code
            }
        }

        public var debugDescription: String {
            switch self {
            case .invalidAuthenticationToken:
                return "user:invalid_authentication_token"
            case .other(let code):
                return code
            }
        }
    }

}

extension APIError: Error {}

extension APIError: Decodable {

    private enum CodingKeys: String, CodingKey {
        case object
        case code
        case description
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(APIErrorCode.self, forKey: .code)
        description = try container.decode(String.self, forKey: .description)
    }

}
