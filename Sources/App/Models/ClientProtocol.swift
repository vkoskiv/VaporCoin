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
					response = receivedGetPeers(json: json)
				case "newPeers":
					response = receivedPeerList(json: json)
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
	
	func receivedGetPeers(json: JSON) -> JSON {
		//Reply with all known peers
		
		var response = JSON()
		
		var structure = [[String: NodeRepresentable]]()
		structure.append(["error": ""])
		structure.append(["id": try! json.get("id")])
		
		var hosts = [NodeRepresentable]()
		
		for host in state.knownHosts {
			hosts.append(host)
		}
		
		structure.append(["result": hosts])
		
		response = try! JSON(node: structure)
		
		return response
	}
	
	func receivedPeerList(json: JSON) -> JSON {
		let asd: Int = try! json.get("id")
		print("Received list of peers from \(asd)")
		let hosts: [String] = try! json.get("result")
		for hostname in hosts {
			//TODO: Ping and confirm before adding
			state.knownHosts.append(hostname)
		}
		print("Added \(hosts.count) nodes")
		
		var structure = [[String: NodeRepresentable]]()
		structure.append(["error": ""])
		structure.append(["id": try! json.get("id")])
		let response = try! JSON(node: structure)
		return response
	}
	
	//Sent requests
	func sendRequest<T>(request: RequestType, to recipient: PeerState?, _ param: T) {
		
		var json = JSON()
		
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
		
		if recipient == nil {
			//Send to all
			for (p, _) in state.peers {
				p.sendRequest(json: json)
			}
		} else {
			
			do {
				try json.set("id", recipient?.id)
			} catch {
				print("can't set id param for \(recipient?.id ?? 414141)")
			}
			
			//Send to specific peer
			recipient?.sendRequest(json: json)
		}
		
	}
	
	func broadcastTransaction(txn: Transaction) -> JSON {
		//TODO
		return JSON()
	}
	
	func getBlock(depth: Int) -> JSON {
		//TODO
		return JSON()
	}
	
	func getPeers() -> JSON {
		var json = JSON()
		try! json.set("method", "getPeers")
		try! json.set("params", "")
		//ID is set in sendRequest
		return json
	}
	
	//Other funcs
	
	//Protocol funcs
	func receivedBlock(block: Block) -> JSON {
		//Check validity, and then remove txns from mempool
		if block.verify() {
			print("Block \(block.blockHash) (\(block.depth)) valid!")
			//Remove block transactions from mempool, as they've been processed already.
			state.memPool.remove(txns: block.txns)
			print("Removed \(block.txns.count) transactions from mempool")
			
			//Block is valid, append
			//TODO: Handle conflicts
			state.blockChain.append(block)
			
			state.blocksSinceDifficultyUpdate += 1
			if state.blocksSinceDifficultyUpdate >= 60 {
				state.updateDifficulty()
			}
			
			//TODO: Restart mining here with new txns
			
			//And broadcast this block to other clients
			broadcastBlock(block: block)
		}
		return JSON()
	}
	
	func broadcastBlock(block: Block) {
		//TODO
		//Called from receivedBlock after verify. Broadcast to everyone except who this came from
	}
	
	func receivedTransaction(txn: Transaction) -> JSON {
		//TODO
		//Check validity, and then add to mempool
		return JSON()
	}
	
	//TODO: Remove this
	func test() throws -> JSON { return JSON() }
	
	//Block from JSON
	func blockFromJSON(json: JSON) -> Block {
		//TODO
		return Block()
	}
	
	//Transaction from JSON
	func transactionFromJSON(json: JSON) -> Transaction {
		//TODO
		return Transaction()
	}
	
}
