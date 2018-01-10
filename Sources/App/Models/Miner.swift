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
	var diffBits: String
	
	//Mining params
	var nonce: Int32 = 0
	var timeStamp: Double = Date().timeIntervalSince1970
	
	//Hardware params
	var threadCount: Int = 1
	
	init(coinbase: String, diffBits: Int, threadCount: Int) {
		print("Starting VaporCoin miner with \(threadCount) threads and a difficulty of \(diffBits) bits")
		self.coinbase = coinbase
		self.diffBits = String(repeatElement("0", count: diffBits))
		self.threadCount = threadCount
	}
	
	func mineBlock(block: Block, completion: @escaping (Block) -> Void) {
		block.nonce = 0
		block.blockHash = block.encoded.sha256
		findHash(block: block) { newBlock in
			completion(newBlock)
		}
	}
	
	func checkDiff(block: Block, difficulty: Double) -> Bool {
		//Check difficulty. Return true if hash is less than or equal to current diff (Valid)
		
		return false
	}
	
	//TODO: add stuff to update the merkleRoot and timestamp periodically
	//TODO: Implement proper difficulty. Perhaps HashCash approach for now, fractional later.
	func findHash(block: Block, completion: @escaping (Block) -> Void) {
		
		
		let concurrentQueue = DispatchQueue(label: "hashQueue", attributes: .concurrent)
		let taskGroup = DispatchGroup()
		
		concurrentQueue.async {
			
			DispatchQueue.concurrentPerform(iterations: self.threadCount) { threadID in
				taskGroup.enter()
				var blockIsFound = false
				let candidate = block.newCopy()
				
				//Start each thread with a nonce at different spot
				candidate.nonce = UInt32(threadID) * (UINT32_MAX/UInt32(self.threadCount))
				
				//TODO: Find a more efficient way to check prefix zeroes.
				while (!candidate.blockHash.binaryString.hasPrefix(self.diffBits)) {
					candidate.nonce += 1
					candidate.timestamp = Date().timeIntervalSince1970
					candidate.blockHash = candidate.encoded.sha256
					if blockIsFound {
						break
					}
				}
				
				if !blockIsFound {
					print("Block found by thread #\(threadID)")
					blockIsFound = true
					completion(candidate)
					taskGroup.leave()
				}
			}
		}
	}
	
	func blockFound(block: Block) {
		//Get user-readable date
		let date = Date(timeIntervalSince1970: block.timestamp)
		let formatter = DateFormatter()
		formatter.dateFormat = "dd-MM-YYYY hh:mm:ss"
		let dateString = formatter.string(from: date)
		
		print("prevHash  : \(block.prevHash.hexString)")
		print("hash      : \(block.blockHash.hexString)")
		print("nonce     : \(block.nonce)")
		print("merkleRoot: \(block.merkleRoot.hexString)")
		print("timestamp : \(block.timestamp) (\(dateString))")
		print("targetDiff: \(block.target)\n")
		print("blockDepth: \(block.depth)\n")
		
		//Update state
		state.blockDepth += 1
		state.blocksSinceDifficultyUpdate += 1
		//And just add block for now
		//TODO: Broadcast block, do checks, and a ton of other stuffs
		state.blockChain.append(block)
	}
	
}
