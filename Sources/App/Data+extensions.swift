//
//  Data+extensions.swift
//  Bits
//
//  Created by Valtteri Koskivuori on 12/09/2017.
//

import Foundation
import Crypto

extension Data {
	
	//Properly working implementations courtesy of Zsolt Váradi
	
	//Return a hex string representation of a Data object
	var hexString: String {
		return map { String($0, radix: 16).leftPadding(toLength: 2, withPad: "0") }.joined()
	}
	
	//Return a binary string representation of a Data object
	var binaryString: String {
		return map { String($0, radix: 2).leftPadding(toLength: 8, withPad: "0") }.joined()
	}
	
	var sha256: Data {
		return Data(bytes: try! Hash.make(.sha256, self), count: 32)
	}
}

extension Data {
	//Some inits I'm not sure are used anywhere?
	//Found where these are used. In the encoded vars, Data(from: someObj)
	init<T>(from value: T) {
		var value = value
		self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
	}
	
	func to<T>(type: T.Type) -> T {
		return self.withUnsafeBytes { $0.pointee }
	}
}

extension String {
	func leftPadding(toLength: Int, withPad character: Character) -> String {
		let stringLength = self.characters.count
		if stringLength < toLength {
			return String(repeatElement(character, count: toLength - stringLength)) + self
		} else {
			return String(self.suffix(toLength))
		}
	}
}

extension String {
	var hexString: String {
		return self.data(using: .utf8)!.hexString
	}
	
	var sha256: Data {
		let hasher = CryptoHasher(hash: .sha256, encoding: .plain)
		return Data(try! hasher.make(self.makeBytes()))
	}
}
