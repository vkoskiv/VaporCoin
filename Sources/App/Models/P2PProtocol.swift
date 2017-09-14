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
	
	//Protocol funcs
	func receivedBlock(block: Block) {
		//Check validity, and then remove txns from mempool
		if block.verify() {
			//Remove block transactions from mempool, as they've been processed already.
			for tx in block.txns {
				state.memPool = state.memPool.filter { $0 != tx}
			}
			
			//Block is valid, append
			//TODO: Handle conflicts
			state.blockChain.append(block)
			
			//And broadcast this block to other clients
			broadcastBlock(block: block)
		}
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
	
	//Internal JSON funcs
	//Broadcast JSON to everyone
	func received(json: JSON) {
		if let msgType = json.object?["msgType"]?.string {
			do {
				switch (msgType) {
				case "newBlock": //New block was found and broadcasted by someone
					//TODO
					receivedBlock(block: blockFromJSON(json: json))
				case "newTransaction":
					receivedTransaction(txn: transactionFromJSON(json: json))
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
