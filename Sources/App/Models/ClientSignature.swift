//
//  Signature.swift
//  VaporCoin
//
//  Created by Valtteri Koskivuori on 12/09/2017.
//

import Foundation
import Signature

class Signature {
	
	var pubKey: CryptoKey? = nil
	var privKey: CryptoKey? = nil
	
	init(pub: CryptoKey, priv: CryptoKey) {
		self.pubKey = pub
		self.privKey = priv
	}
	
	init() {
		self.pubKey = nil
		self.privKey = nil
	}
	
	//TODO
	func signMessage(msg: Data, priv: Signature) -> Data{
		let ecdsaSHA512Sig = try Signature.si
	}
	
	//TODO
	func checkSignature(msg: Data, sign: Signature) -> Bool {
		//'Decrypt' the signature, and then see if hash matches data
		return false
	}
}
