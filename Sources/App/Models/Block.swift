//
//  Block.swift
//  VaporCoin
//
//  Created by Valtteri Koskivuori on 11/09/2017.
//

import Crypto
import Vapor
import Foundation

class Block: NSObject, NSCoding {
	//Block header
	var prevHash: Data
	//FIXME: merkleRoot is computed every single time. Find a way to set+store it whenever transactions are altered.
	var merkleRoot: Data {
		return MerkleRoot.getRootHash(fromTransactions: self.txns)
	}
	var timestamp: Double //Unix Tstamp
	var target: Float
	var nonce: UInt32 //32 bit nonce
	
	var depth: Int
	var txns: [Transaction]
	
	var blockHash: Data
	
	func newCopy() -> Block {
		return Block(prevHash: self.prevHash, depth: self.depth, txns: self.txns, timestamp: self.timestamp, difficulty: self.target, nonce: self.nonce, hash: self.blockHash)
	}
	
	override init() {
		self.prevHash = Data()
		self.timestamp = Date().timeIntervalSince1970
		self.target = 1
		self.nonce = 0
		
		self.depth = 0
		self.txns = []
		self.blockHash = Data()
		
	}
	
	init(prevHash: Data, depth: Int, txns: [Transaction], timestamp: Double, difficulty: Float, nonce: UInt32, hash: Data) {
		self.prevHash = prevHash
		self.depth = depth
		self.txns = txns
		self.timestamp = timestamp
		self.target = difficulty
		self.nonce = nonce
		self.blockHash = hash
	}
	
	/*func encoded() -> Data {
		return NSKeyedArchiver.archivedData(withRootObject: self)
	}*/
	
	var encoded: Data {
		return prevHash + merkleRoot + Data(from: depth) + Data(from: timestamp) + Data(from: target) + Data(from: nonce)
	}
	
	//MARK: Swift encoding logic
	public convenience required init?(coder aDecoder: NSCoder) {
		let prevHash = aDecoder.decodeObject(forKey: "prevHash") as! Data
		let depth = aDecoder.decodeInteger(forKey: "depth")
		let txns = aDecoder.decodeObject(forKey: "txns") as! [Transaction]
		let timestamp = aDecoder.decodeDouble(forKey: "timestamp")
		let difficulty = aDecoder.decodeFloat(forKey: "difficulty")
		let nonce = aDecoder.decodeInt32(forKey: "nonce") as! UInt32
		
		self.init(prevHash: prevHash, depth: depth, txns: txns, timestamp: timestamp, difficulty: difficulty, nonce: nonce, hash: Data())
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(prevHash, forKey: "prevHash")
		aCoder.encode(merkleRoot, forKey: "merkleRoot")
		aCoder.encode(timestamp, forKey: "timestamp")
		aCoder.encode(target, forKey: "target")
		aCoder.encode(nonce, forKey: "nonce")
		
		/*aCoder.encode(depth, forKey: "depth")
		aCoder.encode(txns, forKey: "txns")*/
	}
}

func genesisBlock() -> Block {
	let genesis = Block(prevHash: Data(Bytes(repeatElement(0, count: 32))), depth: 0, txns: [Transaction()], timestamp: 1505278315, difficulty: 1.0, nonce: 0, hash: Data())
	genesis.blockHash = genesis.encoded.sha256
	return genesis
}
