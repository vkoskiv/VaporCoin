//
//  State.swift
//  Bits
//
//  Created by Valtteri Koskivuori on 12/09/2017.
//

import Foundation
import Signature
import Vapor
import Transport
import Sockets

//Current client state
class State: Hashable {
	//Connections to other clients
	//Hostname: Client
	var peers: [TCPJSONClient]
	//Pool of pending transactions to be processed
	var memPool: [Transaction]
	
	//For now, just a in-memory array.
	//Eventually have an in-memory queue of an array of arrays of blocks
	//And then only store to DB when we TRUST a  block
	var blockChain: [Block]
	
	var signature: ClientSignature? = nil

	var p2pProtocol: P2PProtocol
	var minerProtocol: MinerProtocol
	var server: TCPJSONServer?
	var outboundConnections: Int {
		return self.peers.count
	}
	
	var currentDifficulty: Int64
	var blocksSinceDifficultyUpdate: Int
	
	init() {
		print("Initializing client state")
		self.peers = []
		self.memPool = []
		self.blockChain = []
		self.blockChain.append(genesisBlock())
		self.p2pProtocol = P2PProtocol()
		self.minerProtocol = MinerProtocol()
		
		//Blockchain state params
		self.currentDifficulty = 1
		self.blocksSinceDifficultyUpdate = 1
		
		//Listen for requests
		self.server = try? TCPJSONServer()
		try? self.server?.start()
		
		//Set up initial client conns
		initConnections()
		
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
	
	func initConnections() {
		//Hard-coded, known nodes to start querying state from
		let proteus = try! TCPInternetSocket(scheme: "coin", hostname: "proteus.vkoskiv.com", port: 6001)
		let triton  = try! TCPInternetSocket(scheme: "coin", hostname:  "triton.vkoskiv.com", port: 6001)
		var client = try! TCPJSONClient(proteus)
		peers.append(client)
		client = try! TCPJSONClient(triton)
		peers.append(client)
	}
	
	var hashValue: Int {
		return self.hashValue
	}
	
	//MARK: Interact with blockchain
	func getBlockWithHash(hash: Data) -> Block {
		let blocks = self.blockChain.filter { $0.blockHash == hash }
		if blocks.count > 1 {
			print("Found more than 1 block with this hash. Yer blockchain's fucked.")
			return Block()
		}
		return blocks.first!
	}
	
	func getLatestBlock() -> Block {
		return self.blockChain.last!
	}
	
}

func ==(lhs: State, rhs: State) -> Bool {
	return lhs.hashValue == rhs.hashValue
}
