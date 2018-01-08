//
//  Data+extensions.swift
//  Bits
//
//  Created by Valtteri Koskivuori on 12/09/2017.
//

import Foundation
import Crypto

extension Data {
	//Return a hex string representation of a Data object
	var hexString: String {
		return self.map{String($0, radix: 16)}.joined()
	}
	
	var binaryString: String {
		return self.map{String($0, radix: 2)}.joined()
	}
	
	var sha256: Data {
		return Data(try! Hash.make(.sha256, self))
	}
}

extension Data {
	//Some inits I'm not sure are used anywhere?
	init<T>(from value: T) {
		var value = value
		self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
	}
	
	func to<T>(type: T.Type) -> T {
		return self.withUnsafeBytes { $0.pointee }
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
