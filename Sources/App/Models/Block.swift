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
	//Block header
	var prevHash: Data
	//FIXME: merkleRoot is computed every single time. Find a way to set+store it whenever transactions are altered.
	var merkleRoot: Data {
		return MerkleRoot.getRootHash(fromTransactions: self.txns)
	}
	var timestamp: Double //Unix Tstamp
	var target: Float
	var nonce: Int64 //64 bit nonce
	
	var depth: Int
	var txns: [Transaction]
	
	var blockHash: Data
	
	override init() {
		self.prevHash = Data()
		self.timestamp = Date().timeIntervalSince1970
		self.target = 1
		self.nonce = 0
		
		self.depth = 0
		self.txns = []
		self.blockHash = Data()
		
	}
	
	init(prevHash: Data, depth: Int, txns: [Transaction], timestamp: Double, difficulty: Float, nonce: Int64, hash: Data) {
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
	
	func encoded() -> Data {
		return prevHash + merkleRoot + Data(from: depth) + Data(from: timestamp) + Data(from: target) + Data(from: nonce)
	}
	
	func verify() -> Bool {
		//Verify the validity of a block
		//Check that the reported hash matches
		let testHash = self.encoded().sha256
		if self.blockHash != testHash {
			print("Block hash doesn't match")
			return false
		}
		
		//Check that hash is valid (Matches difficulty)
		//FIXME: This is a bit of a hack
		if let hashNum = UInt256(data: NSData(data: self.blockHash)) {
			//HASH < 2^(256-minDifficulty) / currentDifficulty
			if hashNum > (UInt256.max - UInt256(32)) / UInt256(state.currentDifficulty) {
				//Block hash doesn't match current difficulty
				return false
			}
		}
		
		//Check timestamp
		let currentTime: Double = Double(Date().timeIntervalSince1970)
		let maxTimeDeviation: Double = 1800 // 30 minutes
		if self.timestamp < (currentTime - maxTimeDeviation) {
			//Block timestamp more than 30min in past
			return false
		}
		if self.timestamp > (currentTime + maxTimeDeviation) {
			//Block timestamp more than 30min in future
			return false
		}
		
		//Looks good
		return true
	}
	
	//MARK: Swift encoding logic
	public convenience required init?(coder aDecoder: NSCoder) {
		let prevHash = aDecoder.decodeObject(forKey: "prevHash") as! Data
		let depth = aDecoder.decodeInteger(forKey: "depth")
		let txns = aDecoder.decodeObject(forKey: "txns") as! [Transaction]
		let timestamp = aDecoder.decodeDouble(forKey: "timestamp")
		let difficulty = aDecoder.decodeFloat(forKey: "difficulty")
		let nonce = aDecoder.decodeInt64(forKey: "nonce")
		
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
	let genesis = Block(prevHash: Data(), depth: 0, txns: [Transaction()], timestamp: 1505278315, difficulty: 1.0, nonce: 0, hash: Data())
	genesis.blockHash = genesis.encoded().sha256
	return genesis
}

extension Data {
	
	init<T>(from value: T) {
		var value = value
		self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
	}
	
	func to<T>(type: T.Type) -> T {
		return self.withUnsafeBytes { $0.pointee }
	}
}
