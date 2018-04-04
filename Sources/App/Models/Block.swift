//
//  Block.swift
//  VaporCoin
//
//  Created by Valtteri Koskivuori on 11/09/2017.
//

import Crypto
import Vapor
import Foundation

class Block {
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
	
	//TODO: Should this be a computed value?
	var blockHash: Data
	
	func newCopy() -> Block {
		return Block(prevHash: self.prevHash, depth: self.depth, txns: self.txns, timestamp: self.timestamp, difficulty: self.target, nonce: self.nonce, hash: self.blockHash)
	}
	
	init(prevHash: Data = Data(),
		 depth: Int = 0,
		 txns: [Transaction] = [],
		 timestamp: Double = 0,
		 difficulty: Float = 0,
		 nonce: UInt32 = 0,
		 hash: Data = Data()
		) {
		self.prevHash = prevHash
		self.depth = depth
		self.txns = txns
		self.timestamp = timestamp
		self.target = difficulty
		self.nonce = nonce
		self.blockHash = hash
	}
	
	var encoded: Data {
		return prevHash + merkleRoot + Data(from: depth) + Data(from: timestamp) + Data(from: target) + Data(from: nonce)
	}
}

func genesisBlock() -> Block {
	let genesis = Block(prevHash: Data(Bytes(repeatElement(0, count: 32))), depth: 0, txns: [], timestamp: 1505278315, difficulty: 1.0, nonce: 0, hash: Data())
	genesis.blockHash = genesis.encoded.sha256
	return genesis
}
