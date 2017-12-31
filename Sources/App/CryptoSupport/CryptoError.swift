/**
 *  ServerCrypto
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import Foundation
import CTLS

/**
 * The structured representation of an OpenSSL error.
 */

public struct CryptoError: LocalizedError {

    // MARK: - Properties

    /// The code of the error.
    public let code: UInt

    /// The description of the error.
    private let errDescription: String

    public var errorDescription: String {
        return errDescription
    }

    public var localizedDescription: String {
        return errDescription
    }

    // MARK: - Lifecycle

    /**
     * Creates an error descriptor.
     * - parameter code: The code of the error.
     * - parameter localizedDescription: The description of the error.
     */

    private init(code: UInt, errDescription: String) {
        self.code = code
        self.errDescription = errDescription
    }

    // MARK: - Getting the Latest Error

    /**
     * The latest error thrown by the OpenSSL library.
     * - returns: The object describing the latest error.
     */

    public static var latest: CryptoError {

        let code = ERR_get_error()

        var errorStringBuffer = [Int8]()
        ERR_error_string(code, &errorStringBuffer)

        let errDescription = String(cString: &errorStringBuffer)
        return CryptoError(code: code, errDescription: errDescription)

    }

}
