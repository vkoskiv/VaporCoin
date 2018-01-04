//
//  Miner.swift
//  App
//
//  Created by Valtteri Koskivuori on 04/01/2018.
//

import Foundation

class Miner {
	
	//Address
	var coinbase: String
	var difficulty: Int64
	
	//Mining params
	var nonce: Int32 = 0
	var timeStamp: Double = Date().timeIntervalSince1970
	
	init(coinbase: String, diff: Int64) {
		self.coinbase = coinbase
		self.difficulty = diff
	}
	
	func startWorker(block: Block) -> Block {
		block.nonce = 0
		block.blockHash = block.encoded().sha256
		let minedBlock = mine(block: block)
		
		//Get user-readable date
		let date = Date(timeIntervalSince1970: minedBlock.timestamp)
		let formatter = DateFormatter()
		formatter.dateFormat = "dd-MM-YYYY hh:mm:ss"
		let dateString = formatter.string(from: date)
		
		print("Block hash      : \(minedBlock.blockHash.hexString)")
		print("Block prevHash  : \(minedBlock.prevHash.hexString)")
		print("Block nonce     : \(minedBlock.nonce)")
		print("Block depth     : \(minedBlock.depth)")
		print("Block merkleRoot: \(minedBlock.merkleRoot.hexString)")
		print("Block timestamp : \(minedBlock.timestamp) (\(dateString))")
		print("Block targetDiff: \(minedBlock.target)\n")
		return minedBlock
	}
	
	func mine(block: Block) -> Block {
		//Just run the hash till it's found with current diff
		//TODO: Update txns, timestamp...
		/*while (UInt256(data: NSData(data: block.blockHash))! > ((UInt256.max - UInt256(32)) / UInt256(self.difficulty))) {
			block.nonce += 1
			block.blockHash = block.encoded().sha256
		}*/
		
		while (!block.blockHash.hexString.hasPrefix("000")) {
			block.nonce += 1
			block.timestamp = Date().timeIntervalSince1970
			block.blockHash = block.encoded().sha256
		}
		return block
	}
	
}
