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
	
	//For now, just a in-memory array.
	//Eventually have an in-memory queue of an array of arrays of blocks
	//And then only store to DB when we TRUST a  block
	var blockChain: [Block]
	
	var signature: ClientSignature? = nil
	var socket: WebSocket? = nil
	
	//TODO: Separate these two into 2 protocol classes
	var p2pProtocol: P2PProtocol
	var minerProtocol: MinerProtocol
	
	var currentDifficulty: Int64
	var blocksSinceDifficultyUpdate: Int
	
	
	init() {
		print("Initializing client state")
		self.connections = [:]
		self.memPool = []
		self.blockChain = []
		self.blockChain.append(genesisBlock())
		self.p2pProtocol = P2PProtocol()
		self.minerProtocol = MinerProtocol()
		self.currentDifficulty = 1
		self.blocksSinceDifficultyUpdate = 1
		
		var pubKey: CryptoKey
		var privKey: CryptoKey
		do {
			print("Loading crypto keys")
			pubKey = try CryptoKey(path: "/Users/vkoskiv/coinkeys/public.pem", component: .publicKey)
			privKey = try CryptoKey(path: "/Users/vkoskiv/coinkeys/private.pem", component: .privateKey(passphrase:nil))
			
			self.signature = ClientSignature(pub: pubKey, priv: privKey)
		} catch {
			print("Crypto keys not found!")
		}
	}
	
	var hashValue: Int {
		return self.hashValue
	}
	
	
	//MARK: Interact with blockchain
	func getBlockWithHash(hash: Data) -> Block {
		return self.blockChain.filter { $0.blockHash = hash }
	}
	
	func getLatestBlock() -> Block {
		return self.blockChain.last
	}
	
}

func ==(lhs: State, rhs: State) -> Bool {
	return lhs.hashValue == rhs.hashValue
}
