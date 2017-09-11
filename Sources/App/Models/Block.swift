//
//  Block.swift
//  VaporCoin
//
//  Created by Valtteri Koskivuori on 11/09/2017.
//

import Crypto
import Vapor
import Foundation

final class Block {
	var prevHash: Data
	var depth: Int
	var txns: [Transaction]
	var timestamp: Double //Unix Tstamp
	
	var difficulty: Float64
	
	var nonce: Int64 //256 bit hash
	var hash: Data
	
	init() {
		self.prevHash = Data()
		self.depth = 0
		self.txns = []
		self.timestamp = Date().timeIntervalSince1970
		self.difficulty = 1
		self.nonce = 0
		self.hash = Data()
	}
}

/*func blockSum(block: Block) -> Data {
	var data = Data()
	data.append(block.prevHash)
	data.append(Data(bytes: block.depth, count: sizeof(Int)))
	
	for tx in block.txns {
		data.append(tx)
	}
	
	data.append(block.timestamp)
	return data
}*/

func verifyBlock(block: Block) -> Bool {
	return true
}
