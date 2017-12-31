/**
 *  ServerCrypto
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import Foundation
import CryptoSupport
import CTLS

/**
 * A data hasher.
 */

public enum Hasher {

    /// The MD4 hashing algorithm.
    case md4

    /// The MD5 hashing algorithm.
    case md5

    /// The SHA-1 hashing algorithm.
    case sha1

    /// The SHA-224 hashing algorithm.
    case sha224

    /// The SHA-256 hashing algorithm.
    case sha256

    /// The SHA-384 hashing algorithm.
    case sha384

    /// The SHA-512 hashing algorithm.
    case sha512

    /// The RIPEMD-160 hashing algorithm.
    case ripeMd160

    /// A hashing algorithm that always returns an empty hash.
    case null

    /// Creates a message digest description for the hash provider.
    public func makeMessageDigest() ->  UnsafePointer<EVP_MD>? {

        switch self {
        case .md4: return EVP_md4()
        case .md5: return EVP_md5()
        case .sha1: return EVP_sha1()
        case .sha224: return EVP_sha224()
        case .sha256: return EVP_sha256()
        case .sha384: return EVP_sha384()
        case .sha512: return EVP_sha512()
        case .ripeMd160: return EVP_ripemd160()
        case .null: return EVP_md_null()
        }

    }

}

// MARK: - Hashing

extension Hasher {

    /**
     * Compute the hash of bytes.
     *
     * - parameter bytes: The bytes to hash.
     * - throws: This method may throw a `CryptoError` object in case of a failure.
     * - returns: A `Data` object that contains the bytes of the hash.
     */

    public func makeHash<T: Bytes>(for bytes: T) throws -> Data
        where T.Element == UInt8, T.IndexDistance == Int {

            CryptoProvider.load(.digests, .cryptoErrorStrings)

            guard let digestDescription = makeMessageDigest() else {
                throw CryptoError.latest
            }

            guard let context = EVP_MD_CTX_create() else {
                throw CryptoError.latest
            }

            defer {
                EVP_MD_CTX_destroy(context)
            }

            /* Properties */

            var digestLength = UInt32(EVP_MD_size(digestDescription))
            var digest = Data(count: Int(digestLength))

            /* Hashing */

            guard EVP_DigestInit(context, digestDescription) == 1 else {
                throw CryptoError.latest
            }

            let updateResult = bytes.withUnsafeRawBytes {
                return EVP_DigestUpdate(context, $0, bytes.count)
            }

            guard updateResult == 1 else {
                throw CryptoError.latest
            }

            /* Final */

            let finalResult = digest.withUnsafeMutableBytes {
                (mutableBody: UnsafeMutablePointer<UInt8>) -> Int32 in
                return EVP_DigestFinal(context, mutableBody, &digestLength)
            }

            guard finalResult == 1 else {
                throw CryptoError.latest
            }

            return digest.prefix(upTo: Int(digestLength))

    }

}
