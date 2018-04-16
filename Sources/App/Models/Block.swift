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
	var merkleRoot: Data
	var timestamp: Double //Unix Tstamp
	var target: Float
	var nonce: UInt32 //32 bit nonce
	var depth: Int
	
	//Block contents
	var txns: [Transaction] {
		didSet {
			self.merkleRoot = MerkleRoot.getRootHash(fromTransactions: self.txns)
		}
	}
	
	var blockHash: Data {
		return self.encoded.sha256
	}
	
	var encoded: Data {
		return prevHash + merkleRoot + Data(from: depth) + Data(from: timestamp) + Data(from: target) + Data(from: nonce)
	}
	
	var sha256: Data {
		return self.encoded.sha256
	}
	
	func newCopy() -> Block {
		return Block(prevHash: self.prevHash, depth: self.depth, txns: self.txns, timestamp: self.timestamp, difficulty: self.target, nonce: self.nonce)
	}
	
	init(prevHash: Data = Data(),
		 depth: Int = 0,
		 txns: [Transaction] = [],
		 timestamp: Double = 0,
		 difficulty: Float = 0,
		 nonce: UInt32 = 0
		) {
		self.prevHash = prevHash
		self.depth = depth
		self.txns = txns
		self.timestamp = timestamp
		self.target = difficulty
		self.nonce = nonce
		self.merkleRoot = MerkleRoot.getRootHash(fromTransactions: self.txns)
	}
}

func genesisBlock() -> Block {
	let genesis = Block(prevHash: Data(Bytes(repeatElement(0, count: 32))), depth: 0, txns: [], timestamp: 1505278315, difficulty: 1.0, nonce: 0)
	return genesis
}

