//
//  Data+extensions.swift
//  Bits
//
//  Created by Valtteri Koskivuori on 12/09/2017.
//

import Foundation

extension Data {
	//Return a hex string representation of a Data object
	var hexString: String {
		let string = self.map{String($0, radix: 16)}.joined()
		return string
	}
	
	var sha256: Data {
		var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
		self.withUnsafeBytes {
			_ = CC_SHA256($0, CC_LONG(self.count), &hash)
		}
		return Data(bytes: hash)
	}
}

extension String {
	var hexString: String {
		return self.data(using: .utf8)!.hexString
	}
	
	var sha256: Data {
		var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
		self.data(using: .utf8)?.withUnsafeBytes {
			_ = CC_SHA256($0, CC_LONG(self.count), &hash)
		}
		return Data(bytes: hash)
	}
}
