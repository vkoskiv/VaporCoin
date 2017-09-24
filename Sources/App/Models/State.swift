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
	//Currently connected peers
	var peers: [TCPJSONClient]
	//Known hostnames
	var knownHosts: [String]
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
	
	let version: Int = 1
	
	var currentDifficulty: Int64
	var blocksSinceDifficultyUpdate: Int
	var blockDepth: Int
	
	init() {
		print("Initializing client state")
		self.peers = []
		
		self.knownHosts = []
		self.knownHosts.append("192.168.1.75")
		//self.knownHosts.append("proteus.vkoskiv.com")
		//self.knownHosts.append("triton.vkoskiv.com")
		
		self.memPool = []
		self.blockChain = []
		self.blockChain.append(genesisBlock())
		print("\(blockChain.first!.encoded().sha256.hexString)")
		self.p2pProtocol = P2PProtocol()
		self.minerProtocol = MinerProtocol()
		
		//Blockchain state params
		self.currentDifficulty = 1
		self.blocksSinceDifficultyUpdate = 1
		self.blockDepth = 1
		
		//Listen for requests
		self.server = try? TCPJSONServer()
		
		/*DispatchQueue.main.async {
		}*/
		
		DispatchQueue.global(qos: .default).async {
			try? self.server?.start()
		}
		
		//Set up initial client conns
		DispatchQueue.global(qos: .background).async {
			self.initConnections()
		}
		
		//Start syncing on a background thread
		DispatchQueue.global(qos: .background).async {
			DispatchQueue.main.async {
				self.startSync()
			}
		}
		
		/*var pubKey: CryptoKey
		var privKey: CryptoKey
		do {
			print("Loading crypto keys")
			pubKey = try CryptoKey(path: "/Users/vkoskiv/coinkeys/public.pem", component: .publicKey)
			privKey = try CryptoKey(path: "/Users/vkoskiv/coinkeys/private.pem", component: .privateKey(passphrase:nil))
			
			self.signature = ClientSignature(pub: pubKey, priv: privKey)
		} catch {
			print("Crypto keys not found!")
		}*/
	}
	
	func startSync() {
		//Query other nodes for blockchain status, and then sync until latest block
		print("Starting background sync, from block \(state.blockDepth)")
	}
	
	//Get new peers AND get current network status (difficulty, block depth)
	func queryPeers() {
		//Query for new peers to add to list
		//TODO: A ping request to see if node is alive + versioning
		print("Querying for more hostnames from peers")
		for p in peers {
			
		}
	}
	
	func initConnections() {
		//Hard-coded, known nodes to start querying state from
		print("Initializing connections")
		for hostname in self.knownHosts {
			print("Connecting to \(hostname)")
			let sock = try! TCPInternetSocket(scheme: "coin", hostname: hostname, port: 6001)
			var conn: TCPJSONClient
			do {
				conn = try TCPJSONClient(sock)
				print("Connected  to \(sock.hostname)!")
				peers.append(conn)
			} catch {
				print("Failed to connect to \(sock.hostname)")
			}
		}
		queryPeers()
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
	
	func updateDifficulty() {
		//Look at how long last 60 blocks took, and update difficulty
		let startTime = self.blockChain[self.blockChain.endIndex - 60].timestamp
		let timeDiff = self.blockChain.last!.timestamp - startTime
		print("Last 60 blocks took \(timeDiff) seconds")
		//Target is 3600s (1 hour)
		print("Difficulty before: \(self.currentDifficulty)")
		self.currentDifficulty *= Int64(3600 / timeDiff)
		print("Difficulty after:  \(self.currentDifficulty)")
		self.blocksSinceDifficultyUpdate = 0
	}
	
}

func ==(lhs: State, rhs: State) -> Bool {
	return lhs.hashValue == rhs.hashValue
}
