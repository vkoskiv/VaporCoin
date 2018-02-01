/**
 *  ServerCrypto
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import Foundation
import CTLS

/**
 * A key to sign and verify with the HMAC algorithm.
 */

public class HMACKey {

    public let underlyingKeyPointer: UnsafeMutablePointer<EVP_PKEY>

    /**
     * Create a HMAC key with a binary password.
     * - parameter password: The bytes making the password.
     * - throws: In case of failure, this initializer throws a `CryptoError` object.
     */

    public init(password: Data) throws {

        CryptoProvider.load(.digests, .cryptoErrorStrings)

        let optionalKey = password.withUnsafeBytes {
            (buf: UnsafePointer<UInt8>) -> UnsafeMutablePointer<EVP_PKEY>! in
            return EVP_PKEY_new_mac_key(EVP_PKEY_HMAC, nil, buf, Int32(password.count))
        }

        guard let key = optionalKey else {
            throw CryptoError.latest
        }

        underlyingKeyPointer = key

    }

    /**
     * Create a HMAC key with a plain-text password.
     * - parameter password: The plain-text password.
     * - throws: In case of failure, this initializer throws a `CryptoError` object.
     */

    public convenience init(password: String) throws {
        let passwordData = Data(password.utf8)
        try self.init(password: passwordData)
    }

    deinit {
        EVP_PKEY_free(underlyingKeyPointer)
    }

}
