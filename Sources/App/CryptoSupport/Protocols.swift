/**
 *  ServerCrypto
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import Foundation

/// A sequence of bytes.
public typealias Bytes = RandomAccessCollection & MutableCollection & RawBytesProviding

/**
 * Provides a raw bytes-represented version of itself.
 */

public protocol RawBytesProviding {

    /**
     * Executes a closure against the raw bytes in the data's buffer.
     */

    func withUnsafeRawBytes<ResultType>(_ body: (UnsafeRawPointer) throws -> ResultType) rethrows -> ResultType

    /**
     * Executes a closure against the raw bytes in the data's buffer.
     */

    func withUnsafeRawBytes<ResultType>(_ body: (UnsafeMutableRawPointer) throws -> ResultType) rethrows -> ResultType

}

extension Data: RawBytesProviding {

    public func withUnsafeRawBytes<ResultType>(_ body: (UnsafeRawPointer) throws -> ResultType) rethrows -> ResultType {
        return try self.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) in
            try body(UnsafeRawPointer(bytes))
        }
    }

    public func withUnsafeRawBytes<ResultType>(_ body: (UnsafeMutableRawPointer) throws -> ResultType) rethrows -> ResultType {
        return try self.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) in
            try body(UnsafeMutableRawPointer(mutating: bytes))
        }
    }

    public func withAutomaticPointer<ResultType>(_ body: (UnsafePointer<UInt8>) throws -> ResultType) rethrows -> ResultType {
        return try self.withUnsafeBytes {
            try body($0)
        }
    }

    public func withAutomaticPointer<ResultType>(_ body: (UnsafeMutablePointer<UInt8>) throws -> ResultType) rethrows -> ResultType {

        var copy = self

        return try copy.withUnsafeMutableBytes {
            try body($0)
        }
    }

}

extension Array: RawBytesProviding {

    public func withUnsafeRawBytes<ResultType>(_ body: (UnsafeRawPointer) throws -> ResultType) rethrows -> ResultType {
        let rawPointer = UnsafeRawPointer(self)
        return try body(rawPointer)
    }

    public func withUnsafeRawBytes<ResultType>(_ body: (UnsafeMutableRawPointer) throws -> ResultType) rethrows -> ResultType {
        let rawPointer = UnsafeMutableRawPointer(mutating: self)
        return try body(rawPointer)
    }

}
