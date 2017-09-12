//
//  P2P.swift
//  Bits
//
//  Created by Valtteri Koskivuori on 12/09/2017.
//

import Vapor
import Foundation

//Simple custom P2P protocol handling
class JSONProtocol {
	
	//Protocol funcs
	func receivedBlock(block: Block) {
		//Check validity, and then remove txns from mempool
	}
	
	func receivedTransaction(txn: Transaction) {
		//Check validity, and then add to mempool
	}
	
	func broadcastBlock(block: Block) {
		//Called from receivedBlock after verify. Broadcast to everyone except who this came from
	}
	
	func broadcastTransaction(txn: Transaction) {
		//Called from receivedTransaction OR when creating one, broadcast to everyone except who came from when received
	}
	
	//Internal transmit funcs
	//Broadcast JSON to everyone
	func broadcast(json: JSON) {
		
	}
	//Send to specific client
	func send(json: JSON) {
		
	}
	
}
