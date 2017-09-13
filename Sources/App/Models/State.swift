//
//  State.swift
//  Bits
//
//  Created by Valtteri Koskivuori on 12/09/2017.
//

import Foundation
import Signature
import Vapor

//Current client state
class State: Hashable {
	
	//Connections to other clients
	var connections: [State: WebSocket]
	//Pool of pending transactions to be processed
	var memPool: [Transaction]
	
	var signature: ClientSignature? = nil
	var socket: WebSocket? = nil
	
	var currentDifficulty: Int64
	
	init() {
		
		self.connections = [:]
		self.memPool = []
		
		var pubKey: CryptoKey
		var privKey: CryptoKey
		do {
			pubKey = try CryptoKey(path: "/Users/vkoskiv/coinkeys/public.pem", component: .publicKey)
			privKey = try CryptoKey(path: "/Users/vkoskiv/coinkeys/private.pem", component: .privateKey(passphrase:nil))
			
			self.signature = ClientSignature(pub: pubKey, priv: privKey)
		} catch {
			print("Crypto keys not found!")
		}
		self.currentDifficulty = 1
	}
	
	var hashValue: Int {
		return self.hashValue
	}
	
}

func ==(lhs: State, rhs: State) -> Bool {
	return lhs.hashValue == rhs.hashValue
}
