//
//  ClientSignature.swift
//  VaporCoin
//
//  Created by Valtteri Koskivuori on 12/09/2017.
//

import Foundation
import Signature

class ClientSignature {
	
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
	
	func signTransaction(txn: Transaction, priv: ClientSignature) -> Data {
		return Data()
	}
	
	//TODO
	func signMessage(msg: Data, priv: ClientSignature) -> Data {
		let megaRandomBytes = [0x1a, 0x2b, 0x3c, 0x4d, 0x5e, 0x6f]
		//let ecdsaSHA512Sig = try Signature.sign(message: msg, with: priv.privKey, using: .sha512)
		//let ecdsaPrivateKey = try! CryptoKey(path: "/path/to/ecdsa_privateKey.pem", component: .privateKey(passphrase: nil))
		//let ecdsaSHA512Sig = try Signature.sign(message: megaRandomBytes, with: ecdsaPrivateKey, using: .sha512)
		//let newSignatureee = try Signature.si
		return Data()
	}
	
	//TODO
	func checkSignature(msg: Data, sign: ClientSignature) -> Bool {
		//'Decrypt' the signature, and then see if hash matches data
		return false
	}
}
