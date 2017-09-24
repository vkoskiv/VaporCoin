//
//  P2PProtocol.swift
//  Bits
//
//  Created by Valtteri Koskivuori on 12/09/2017.
//

import Vapor
import Foundation

public enum RequestType {
	case getVersion    //Get version (Also pings)
	case getBlock      //Get block
	case getDifficulty  //Get current difficulty
	case newTransaction //Send new transaction
	case getPeers      //Get a list of hostnames
}

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
		if let reqType = json.object?["method"]?.string {
			do {
				switch (reqType) {
				case "newBlock": //New block was found and broadcasted by someone
					response = receivedBlock(block: blockFromJSON(json: json))
				case "newTransaction":
					response = receivedTransaction(txn: transactionFromJSON(json: json))
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
				case "getPeers":
					response = receivedGetPeers()
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
	
	func receivedGetPeers() -> JSON {
		//Reply with all known peers
		
		var json = JSON()
		
		var structure = [[String: NodeRepresentable]]()
		structure.append(["error": ""])
		structure.append(["id": 0])
		
		var hosts = [NodeRepresentable]()
		
		for host in state.knownHosts {
			hosts.append(host)
		}
		
		structure.append(["result": hosts])
		
		json = try! JSON(node: structure)
		
		return json
	}
	
	//Sent requests
	func sendRequest<T>(request: RequestType, to: TCPJSONClient?, _ param: T) -> JSON {
		
		var json = JSON()
		var response = JSON()
		
		switch (request) {
		case .newTransaction:
			json = broadcastTransaction(txn: param as! Transaction)
		case .getBlock:
			json = getBlock(depth: param as! Int)
		case .getPeers:
			json = getPeers()
		default:
			json = JSON()
		}
		
		guard to != nil else {
			//Send to all
			for p in state.peers {
				do {
					json = try p.sendRequest(json: json)
				} catch {
					print("Failed to send request: \(json.string ?? "oops")")
				}
			}
			return json //Why do we need this???
		}
		
		//Send to a specific peer
		do {
			response = try to!.sendRequest(json: json)
		} catch {
			print("Failed to send request: \(String(describing: json.string)) to \(String(describing: to?.hostname))")
		}
		
		return response
	}
	
	func broadcastTransaction(txn: Transaction) -> JSON {
		return JSON()
	}
	
	func getBlock(depth: Int) -> JSON {
		return JSON()
	}
	
	func getPeers() -> JSON {
		var json = JSON()
		try! json.set("method", "getPeers")
		try! json.set("params", "")
		try! json.set("id", 0)
		return json
	}
	
	//Other funcs
	
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
			state.blockDepth += 1
			if state.blocksSinceDifficultyUpdate >= 60 {
				state.updateDifficulty()
			}
			
			//And broadcast this block to other clients
			broadcastBlock(block: block)
		}
		return JSON()
	}
	
	func broadcastBlock(block: Block) {
		//Called from receivedBlock after verify. Broadcast to everyone except who this came from
	}
	
	func receivedTransaction(txn: Transaction) -> JSON {
		//Check validity, and then add to mempool
		return JSON()
	}
	
	func test() throws -> JSON { return JSON() }
	
	//Block from JSON
	func blockFromJSON(json: JSON) -> Block {
		return Block()
	}
	
	//Transaction from JSON
	func transactionFromJSON(json: JSON) -> Transaction {
		return Transaction()
	}
	
}
