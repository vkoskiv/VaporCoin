//
//  MinerProtocol.swift
//  VaporCoin
//
//  Created by Valtteri Koskivuori on 13/09/2017.
//

import Vapor
import Foundation

//Simple custom Miner protocol handling
class MinerProtocol {
	
	//Protocol funcs
	func receivedNewBlock(block: Block) {
		//Check validity, and then remove txns from mempool
		//TODO: Check block validity
		state.blockChain.append(block)
	}
	
	func sendTransaction(txn: Transaction) {
		//New transaction confirmed, send to miner? How do we determine which tx to remove from miner?
		//Have miner just observe CLIENT mempool?
	}
	
	func sendTransactions() {
		//TODO
	}
	
	//Internal JSON funcs
	func received(json: JSON) {
		if let msgType = json.object?["msgType"]?.string {
			do {
				switch (msgType) {
				case "newBlock": //New block was found and broadcasted by someone
					//TODO
					try test()
				case "newTransaction":
					try test()
				case "existingBlock": //Requested some block
					//TODO
					try test()
				case "getBlocks": //Send blocks to sender
					//TODO
					try test()
				case "getLatestBlock": //Send latest block to sender
					//TODO
					try test()
				case "getDifficulty": //Send difficulty to sender
					//TODO
					try test()
				default:
					//TODO
					try test()
				}
			} catch {
				print("fuck")
			}
		}
	}
	
	func test() throws {}
	
	//Send to miner
	func send(json: JSON) {
		
	}
	
	//Block from JSON
	func blockFromJSON(json: JSON) -> Block {
		return Block()
	}
	
	//Transaction from JSON
	func transactionFromJSON(json: JSON) -> Transaction {
		return Transaction()
	}
	
}
