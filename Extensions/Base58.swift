//
//  Base58.swift
//  NeoSwift
//
//  Created by Luís Silva on 11/09/17.
//  This file is MIT licensed from NeoSwift
//  Copyright © 2017 drei. All rights reserved.
//
import Foundation

struct Base58 {
	static let base58Alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
	
	// Encode
	static func base58FromBytes(_ bytes: Data) -> String {
		var bytes = bytes
		var zerosCount = 0
		var length = 0
		
		for b in bytes {
			if b != 0 { break }
			zerosCount += 1
		}
		
		bytes.removeFirst(zerosCount)
		
		let size = bytes.count * 138 / 100 + 1
		
		var base58: [UInt8] = Array(repeating: 0, count: size)
		for b in bytes {
			var carry = Int(b)
			var i = 0
			
			for j in 0...base58.count-1 where carry != 0 || i < length {
				carry += 256 * Int(base58[base58.count - j - 1])
				base58[base58.count - j - 1] = UInt8(carry % 58)
				carry /= 58
				i += 1
			}
			
			assert(carry == 0)
			
			length = i
		}
		
		// skip leading zeros
		var zerosToRemove = 0
		var str = ""
		for b in base58 {
			if b != 0 { break }
			zerosToRemove += 1
		}
		base58.removeFirst(zerosToRemove)
		
		while 0 < zerosCount {
			str = "\(str)1"
			zerosCount -= 1
		}
		
		for b in base58 {
			str = "\(str)\(base58Alphabet[String.Index(encodedOffset: Int(b))])"
		}
		
		return str
	}
	
	// Decode
	static func bytesFromBase58(_ base58: String) -> Data {
		// remove leading and trailing whitespaces
		var string = base58.trimmingCharacters(in: CharacterSet.whitespaces)
		
		guard !string.isEmpty else { return Data() }
		
		var zerosCount = 0
		var length = 0
		for c in string.characters {
			if c != "1" { break }
			zerosCount += 1
		}
		
		let size = string.lengthOfBytes(using: String.Encoding.utf8) * 733 / 1000 + 1 - zerosCount
		var base58: [UInt8] = Array(repeating: 0, count: size)
		for c in string.characters where c != " " {
			// search for base58 character
			guard let base58Index = base58Alphabet.index(of: c) else { return Data() }
			
			var carry = base58Index.encodedOffset
			var i = 0
			for j in 0...base58.count where carry != 0 || i < length {
				carry += 58 * Int(base58[base58.count - j - 1])
				base58[base58.count - j - 1] = UInt8(carry % 256)
				carry /= 256
				i += 1
			}
			
			assert(carry == 0)
			length = i
		}
		
		// skip leading zeros
		var zerosToRemove = 0
		
		for b in base58 {
			if b != 0 { break }
			zerosToRemove += 1
		}
		base58.removeFirst(zerosToRemove)
		
		var result: Data = Data(capacity: zerosCount)//= Array(repeating: 0, count: zerosCount)
		for b in base58 {
			result.append(b)
		}
		return result
	}
}

/*extension Array where Element == UInt8 {
	public var base58EncodedString: String {
		guard !self.isEmpty else { return "" }
		return Base58.base58FromBytes(self)
	}
	
	public var base58CheckEncodedString: String {
		var bytes = self
		let checksum = [UInt8](bytes.sha256.sha256[0..<4])
		
		bytes.append(contentsOf: checksum)
		
		return Base58.base58FromBytes(bytes)
	}
}*/

extension Data {
	public var base58: String {
		return Base58.base58FromBytes(self)
	}
}

extension String {
	/*public var base58EncodedString: String {
		return [UInt8](utf8).base58EncodedString
	}*/
	
	public var base58DecodedData: Data? {
		let bytes = Base58.bytesFromBase58(self)
		return Data(bytes)
	}
	
	/*public var base58CheckDecodedData: Data? {
		guard let bytes = self.base58CheckDecodedBytes else { return nil }
		return Data(bytes)
	}*/
	
	/*public var base58CheckDecodedBytes: [UInt8]? {
		var bytes = Base58.bytesFromBase58(self)
		guard 4 <= bytes.count else { return nil }
		
		let checksum = [UInt8](bytes[bytes.count-4..<bytes.count])
		bytes = [UInt8](bytes[0..<bytes.count-4])
		
		let calculatedChecksum = [UInt8](bytes.sha256.sha256[0...3])
		if checksum != calculatedChecksum { return nil }
		
		return bytes
	}
	
	public var littleEndianHexToUInt: UInt {
		return UInt(self.dataWithHexString().bytes.reversed().fullHexString,radix: 16)!
	}*/
	
}

extension Array where Element == UInt8 {
	public var hexString: String {
		return self.map { return String(format: "%x", $0) }.joined()
	}
	
	public var hexStringWithPrefix: String {
		return "0x\(hexString)"
	}
	
	public var fullHexString: String {
		return self.map { return String(format: "%02x", $0) }.joined()
	}
	
	public var fullHexStringWithPrefix: String {
		return "0x\(fullHexString)"
	}
	
	mutating public func removeTrailingZeros() {
		for i in (0..<self.endIndex).reversed() {
			guard self[i] == 0 else {
				break
			}
			self.remove(at: i)
		}
	}
	
	func xor(other: [UInt8]) -> [UInt8] {
		assert(self.count == other.count)
		
		var result: [UInt8] = []
		for i in 0..<self.count {
			result.append(self[i] ^ other[i])
		}
		return result
	}
}
