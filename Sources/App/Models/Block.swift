//
//  Block.swift
//  VaporCoin
//
//  Created by Valtteri Koskivuori on 11/09/2017.
//

import Crypto
import Vapor
import Foundation

final class Block: NSObject, NSCoding {
	
	//MARK: Swift encoding logic
	
	public convenience required init?(coder aDecoder: NSCoder) {
		let prevHash = aDecoder.decodeObject(forKey: "prevHash") as! Data
		let depth = aDecoder.decodeInteger(forKey: "depth")
		let txns = aDecoder.decodeObject(forKey: "txns") as! [Transaction]
		let timestamp = aDecoder.decodeDouble(forKey: "timestamp")
		let difficulty = aDecoder.decodeFloat(forKey: "difficulty")
		let nonce = aDecoder.decodeInt64(forKey: "nonce")
		let blockHash = aDecoder.decodeObject(forKey: "hash") as! Data
		
		self.init(prevHash: prevHash, depth: depth, txns: txns, timestamp: timestamp, difficulty: difficulty, nonce: nonce, hash: blockHash)
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(prevHash, forKey: "prevHash")
		aCoder.encode(depth, forKey: "depth")
		aCoder.encode(txns, forKey: "txns")
		aCoder.encode(timestamp, forKey: "timestamp")
		aCoder.encode(difficulty, forKey: "difficulty")
		aCoder.encode(nonce, forKey: "nonce")
		aCoder.encode(blockHash, forKey: "blockHash")
	}
	
	//Class
	var prevHash: Data
	var depth: Int
	var txns: [Transaction]
	var timestamp: Double //Unix Tstamp
	
	var difficulty: Float
	
	var nonce: Int64 //256 bit hash
	var blockHash: Data
	
	override init() {
		self.prevHash = Data()
		self.depth = 0
		self.txns = []
		self.timestamp = Date().timeIntervalSince1970
		self.difficulty = 1
		self.nonce = 0
		self.blockHash = Data()
	}
	
	init(prevHash: Data, depth: Int, txns: [Transaction], timestamp: Double, difficulty: Float, nonce: Int64, hash: Data) {
		self.prevHash = prevHash
		self.depth = depth
		self.txns = txns
		self.timestamp = timestamp
		self.difficulty = difficulty
		self.nonce = nonce
		self.blockHash = hash
	}
	
	func encoded() -> Data {
		//Encode block into a data stream, for hashes
		//TODO
		return Data()
	}
	
	func verify() -> Bool {
		return true
	}
}
