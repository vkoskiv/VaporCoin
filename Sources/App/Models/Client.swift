//
//  Client.swift
//  Bits
//
//  Created by Valtteri Koskivuori on 12/09/2017.
//

import Foundation
import Signature
import Vapor

class Client: Hashable {
	var signature: Signature? = nil
	var socket: WebSocket? = nil
	
	var currentDifficulty: Int64
	
	
	init() {
		
		var pubKey: CryptoKey
		var privKey: CryptoKey
		do {
			pubKey = try CryptoKey(path: "/Users/vkoskiv/coinkeys/coinpublic.pem", component: .publicKey)
			privKey = try CryptoKey(path: "/Users/vkoskiv/coinkeys/coinprivate.pem", component: .privateKey(passphrase:"power"))
			
			self.signature = Signature(pub: pubKey, priv: privKey)
		} catch {
			print("Crypto keys not found!")
		}
		self.currentDifficulty = 1
	}
	
	var hashValue: Int {
		return self.hashValue
	}
}

func ==(lhs: Client, rhs: Client) -> Bool {
	return lhs.hashValue == rhs.hashValue
}
