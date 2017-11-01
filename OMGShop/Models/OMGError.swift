//
//  OMGError.swift
//  OMGShop
//
//  Created by Mederic Petit on 20/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit
import OmiseGO

enum OMGError: Error {

    case missingRequiredFields
    case unexpected
    case apiError(error: APIError)
    case omiseGOError(error: OmiseGOError)
    case other(error: Error)

    var message: String {
        switch self {
        case .missingRequiredFields:
            return "error.missing_required_fields".localized()
        case .unexpected:
            return "error.unexpected".localized()
        case .apiError(error: let apiError):
            return apiError.description
        case .omiseGOError(error: let error):
            return error.description
        case .other(error: let error):
            return error.localizedDescription
        }
    }

}

extension OMGError: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String { return self.message }
    public var debugDescription: String { return self.message }
}

extension OMGError: LocalizedError {
    public var errorDescription: String { return self.message }
    public var localizedDescription: String { return self.message }
}
