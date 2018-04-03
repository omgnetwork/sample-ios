//
//  OMGShopError.swift
//  OMGShop
//
//  Created by Mederic Petit on 20/10/17.
//  Copyright © 2017-2018 Omise Go Ptd. Ltd. All rights reserved.
//

import OmiseGO

enum OMGShopError: Error {

    case missingRequiredFields
    case unexpected
    case api(error: APIError)
    case omiseGO(error: OMGError)
    case other(error: Error)

    var message: String {
        switch self {
        case .missingRequiredFields:
            return "error.missing_required_fields".localized()
        case .unexpected:
            return "error.unexpected".localized()
        case .api(error: let apiError):
            return apiError.description
        case .omiseGO(error: let error):
            return error.description
        case .other(error: let error):
            return error.localizedDescription
        }
    }

}

extension OMGShopError: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String { return self.message }
    public var debugDescription: String { return self.message }
}

extension OMGShopError: LocalizedError {
    public var errorDescription: String? { return self.message }
    public var localizedDescription: String { return self.message }
}
