//
//  P2PProtocol.swift
//  Bits
//
//  Created by Valtteri Koskivuori on 12/09/2017.
//

import Vapor
import Foundation

//Simple custom P2P protocol handling
class P2PProtocol {
	
	/*
	JSON-RPC 1.0
	Request:
	method, params, id
	
	Response:
	result, error, id
	
	Notification
	method, params, id = null
	*/
	
	/*
	Todo:
	
	Requests:
	getBlock(s) - param is current latest block (Bundle multiple encoded blocks? getBlock-response loop?)
	getDifficulty - Get current difficulty
	
	
	Broadcasts:
	newTransaction - New transaction
	newBlock - New, freshly mined block
	*/
	
	//JSON request handler
	func received(json: JSON) -> JSON {
		var response = JSON()
		if let msgType = json.object?["msgType"]?.string {
			do {
				switch (msgType) {
				case "newBlock": //New block was found and broadcasted by someone
					response = receivedBlock(block: blockFromJSON(json: json))
				case "newTransaction":
					receivedTransaction(txn: transactionFromJSON(json: json))
				case "existingBlock": //Requested some block
					//TODO
					return try test()
				case "getBlocks": //Send blocks to sender
					//TODO
					return try test()
				case "getLatestBlock": //Send latest block to sender
					//TODO
					return try test()
				case "getDifficulty": //Send difficulty to sender
					//TODO
					return try test()
				default:
					//TODO
					return try test()
				}
			} catch {
				print("fuck")
			}
		}
		//Send reply
		return response
	}
	
	func updateDifficulty() {
		//Look at how long last 60 blocks took, and update difficulty
		let startTime = state.blockChain[state.blockChain.endIndex - 60].timestamp
		let timeDiff = state.blockChain.last!.timestamp - startTime
		print("Last 60 blocks took \(timeDiff) seconds")
		//Target is 3600s (1 hour)
		print("Difficulty before: \(state.currentDifficulty)")
		state.currentDifficulty *= Int64(3600 / timeDiff)
		print("Difficulty after:  \(state.currentDifficulty)")
		state.blocksSinceDifficultyUpdate = 0
	}
	
	//Protocol funcs
	func receivedBlock(block: Block) -> JSON {
		//Check validity, and then remove txns from mempool
		if block.verify() {
			print("Block \(block.depth) valid!")
			//Remove block transactions from mempool, as they've been processed already.
			for tx in block.txns {
				state.memPool = state.memPool.filter { $0 != tx}
			}
			print("Removed \(block.txns.count) transactions from mempool")
			
			//Block is valid, append
			//TODO: Handle conflicts
			state.blockChain.append(block)
			
			state.blocksSinceDifficultyUpdate += 1
			if state.blocksSinceDifficultyUpdate >= 60 {
				updateDifficulty()
			}
			
			//And broadcast this block to other clients
			broadcastBlock(block: block)
		}
		return JSON()
	}
	
	func broadcastBlock(block: Block) {
		//Called from receivedBlock after verify. Broadcast to everyone except who this came from
	}
	
	func receivedTransaction(txn: Transaction) {
		//Check validity, and then add to mempool
	}
	
	func broadcastTransaction(txn: Transaction) {
		//Called from receivedTransaction OR when creating one, broadcast to everyone except who came from when received
	}
	
	func test() throws -> JSON { return JSON() }
	
	func broadcast(json: JSON) {
		
	}
	//Send to specific client
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
