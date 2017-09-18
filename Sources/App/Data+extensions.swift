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
		let string = self.map{String($0, radix: 16)}.joined()
		return string
	}
	
	var sha256: Data {
		let hasher = CryptoHasher(hash: .sha256, encoding: .plain)
		return Data(try! hasher.make(self))
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
