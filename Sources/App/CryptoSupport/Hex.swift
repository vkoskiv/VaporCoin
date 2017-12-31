/**
 *  ServerCrypto
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import Foundation

// MARK: - Get Hex from Data

extension Data {

    /**
     * The hexadecimal text representation of the data.
     * - note: The returned string is lowercased.
     */

    public var hexString: String {

        return reduce("") {
            (string, nextByte) in
            return string + String(format: "%02x", nextByte)
        }

    }

}

// MARK: - Create Data from Hex

extension Data {

    /**
     * Extracts the bytes of a hex string.
     * - parameter hexString: The string.
     */

    public init?(hexString: String) {

        var itetator = hexString.makeIterator()

        var bytes = Data()

        while let h1 = itetator.next() {

            var hexSequence = String(h1)

            if let h2 = itetator.next() {
                hexSequence += String(h2)
            } else {
                hexSequence.insert("0", at: hexSequence.startIndex)
            }

            guard let byte = UInt8(hexSequence, radix: 16) else {
                return nil
            }

            bytes.append(byte)

        }

        self = bytes

    }

}
