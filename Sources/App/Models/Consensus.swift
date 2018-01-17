//
//  Consensus.swift
//  App
//
//  Created by Valtteri Koskivuori on 10/01/2018.
//

import Foundation

let maxTransactionTimeDeviation: Double = 300 //5 minutes
let maxBlockTimeDeviation: Double = 1800 //30 minutes

//Minimum number of blocks before a coinbase transaction can be spent
let coinbaseMaturity: Int = 50

/*
In this file, funcs for verifying everything.
*/

//Consensus protocol
extension Transaction {
	func currentBlockReward() -> Int64 {
		var fullAmount: Int64 = 5000000000
		
		//Figure out current block reward
		//Block reward is halved every 2 102 400 blocks
		
		let divCount: Int = state.blockDepth / 2102400
		
		for _ in 0..<divCount {
			fullAmount /= 2
		}
		
		return fullAmount
	}
}

//Transaction verification
extension Transaction {
	func verifyTransaction() -> Bool {
		//Check that output <= input
		//Check timestamp
		//Check addresses?
		return false
	}
}

//Block verification
extension Block {
	func verify() -> Bool {
		//Verify the validity of a block
		//Check that the reported hash matches
		let testHash = self.encoded.sha256
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
}
