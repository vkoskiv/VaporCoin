/**
 *  ServerCrypto
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import Foundation
import CryptoSupport
import Hash
import CTLS

/**
 * An object that can sign messages.
 */

public enum Signer {

    /// An HMAC signer.
    case hmac(HMACKey)

    /// A key-pair based signer (RSA, ECDSA, ...).
    case asymmetric(AsymmetricKey)

    var rawKey: UnsafeMutablePointer<EVP_PKEY> {

        switch self {
        case .hmac(let key):
            return key.underlyingKeyPointer

        case .asymmetric(let key):
            return key.keyContainer.underlyingKeyPointer

        }

    }

}

// MARK: - Signature

extension Signer {

    /**
     * Signs a message with the specified key and hasher.
     * - parameter message: The message to sign.
     * - parameter hasher: The hasher to use to generate the signature hash.
     * - returns: The bytes containing signature of the message.
     * - throws: A `CryptoError` on failure.
     */

    public func sign<T: Bytes>(message: T, with hasher: Hasher) throws -> Data
        where T.Element == UInt8, T.IndexDistance == Int {

            CryptoProvider.load(.digests, .ciphers, .cryptoErrorStrings)

            /* Pointers */

            guard let messageDigest = hasher.makeMessageDigest() else {
                throw CryptoError.latest
            }

            guard let context = EVP_MD_CTX_create() else {
                throw CryptoError.latest
            }

            defer {
                EVP_MD_CTX_destroy(context)
            }

            /* Signature */

            guard EVP_DigestSignInit(context, nil, messageDigest, nil, rawKey) == 1 else {
                throw CryptoError.latest
            }

            let updateResult = message.withUnsafeRawBytes {
                EVP_DigestUpdate(context, $0, message.count)
            }

            guard updateResult == 1 else {
                throw CryptoError.latest
            }

            /* Final */

            var signatureLength = 0

            guard EVP_DigestSignFinal(context, nil, &signatureLength) == 1 else {
                throw CryptoError.latest
            }

            var signature = Data(count: signatureLength)

            let signatureResult = signature.withUnsafeMutableBytes {
                (body: UnsafeMutablePointer<UInt8>) -> Int32 in
                EVP_DigestSignFinal(context, body, &signatureLength)
            }

            guard signatureResult == 1 else {
                throw CryptoError.latest
            }

            return signature.prefix(upTo: signatureLength)

    }

    /**
     * Verifies the signature for a given message and hasher.
     * - parameter signature: The signature to verify.
     * - parameter message: The message to match with the signature.
     * - parameter hasher: The hasher used to generate the signature hash.
     * - returns: Whether the signature is valid for the message.
     * - throws: A `CryptoError` on failure.
     */

    public func verify<T: Bytes>(signature: Data, for message: T, with hasher: Hasher) throws -> Bool
        where T.Element == UInt8, T.IndexDistance == Int {

            CryptoProvider.load(.digests, .ciphers, .cryptoErrorStrings)

            switch self {
            case .asymmetric:
                return try verify_evp(signature: signature, for: message, with: hasher)

            case .hmac:
                return try verify_hmac(signature: signature, for: message, with: hasher)

            }


    }

    private func verify_evp<T: Bytes>(signature: Data, for message: T, with hasher: Hasher) throws -> Bool
        where T.Element == UInt8, T.IndexDistance == Int {

            var mutableSignature = signature

            guard let messageDigest = hasher.makeMessageDigest() else {
                throw CryptoError.latest
            }

            guard let context = EVP_MD_CTX_create() else {
                throw CryptoError.latest
            }

            defer {
                EVP_MD_CTX_destroy(context)
            }

            /* Verification */

            guard EVP_DigestVerifyInit(context, nil, messageDigest, nil, rawKey) == 1 else {
                throw CryptoError.latest
            }

            let updateResult = message.withUnsafeRawBytes {
                EVP_DigestUpdate(context, $0, message.count)
            }

            guard updateResult == 1 else {
                throw CryptoError.latest
            }

            /* Final */

            let verificationResult: Int32 = signature.withAutomaticPointer {
                return EVP_DigestVerifyFinal(context, $0, signature.count)
            }

            return verificationResult == 1

    }

    private func verify_hmac<T: Bytes>(signature: Data, for message: T, with hasher: Hasher) throws -> Bool
        where T.Element == UInt8, T.IndexDistance == Int {

            let expectedSignature = try self.sign(message: message, with: hasher)

            guard expectedSignature.count == signature.count else {
                return false
            }

            return expectedSignature.withUnsafeRawBytes {
                expectedPtr in

                signature.withUnsafeRawBytes {
                    signaturePtr in
                    return CRYPTO_memcmp(signaturePtr, expectedPtr, signature.count) == 0
                }

            }

    }

}
