//
//  Signature.swift
//  VaporCoin
//
//  Created by Valtteri Koskivuori on 12/09/2017.
//

import Foundation

class Signature {
	
	//TODO
	func signMessage(msg: Data, priv: Signature) -> Data{
		//Hash the message and 'encrypt' it
		return Data()
	}
	
	//TODO
	func checkSignature(msg: Data, sign: Signature) -> Bool {
		//'Decrypt' the signature, and then see if hash matches data
		return false
	}
}
