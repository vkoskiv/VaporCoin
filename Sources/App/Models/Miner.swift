//
//  Miner.swift
//  App
//
//  Created by Valtteri Koskivuori on 04/01/2018.
//

import Foundation

class Miner {
	
	//static let shared = Miner()
	
	//Address
	var coinbase: String
	var difficulty: Int64
	
	//Mining params
	var nonce: Int32 = 0
	var timeStamp: Double = Date().timeIntervalSince1970
	
	init(coinbase: String, diff: Int64) {
		print("Starting VaporCoin miner")
		self.coinbase = coinbase
		self.difficulty = diff
	}
	
	func mineBlock(block: Block, completion: @escaping (Block) -> Void) {
		block.nonce = 0
		block.blockHash = block.encoded().sha256
		findHash(block: block) { newBlock in
			completion(newBlock)
		}
	}
	
	//TODO: Make findHash multi-threaded, and add stuff to update the merkleRoot timestamp periodically
	func findHash(block: Block, completion: @escaping (Block) -> Void) {
		//Just run the hash till it's found with current diff
		//TODO: Update txns, timestamp...
		
		var blockIsFound = false
		
		DispatchQueue.global(qos: .userInitiated).async {
			let candidate = block
			while (!candidate.blockHash.hexString.hasPrefix("00")) {
				candidate.nonce += 1
				candidate.timestamp = Date().timeIntervalSince1970
				candidate.blockHash = candidate.encoded().sha256
				if blockIsFound {
					break
				}
			}
			blockIsFound = true
			completion(candidate)
		}
	}
	
	func blockFound(block: Block) {
		//Get user-readable date
		let date = Date(timeIntervalSince1970: block.timestamp)
		let formatter = DateFormatter()
		formatter.dateFormat = "dd-MM-YYYY hh:mm:ss"
		let dateString = formatter.string(from: date)
		
		print("Block hash      : \(block.blockHash.hexString)")
		print("Block prevHash  : \(block.prevHash.hexString)")
		print("Block nonce     : \(block.nonce)")
		print("Block depth     : \(block.depth)")
		print("Block merkleRoot: \(block.merkleRoot.hexString)")
		print("Block timestamp : \(block.timestamp) (\(dateString))")
		print("Block targetDiff: \(block.target)\n")
		
		//Update state
		state.blockDepth += 1
		state.blocksSinceDifficultyUpdate += 1
		//And just add block for now
		//TODO: Broadcast block, do checks, and a ton of other stuffs
		state.blockChain.append(block)
	}
	
}
