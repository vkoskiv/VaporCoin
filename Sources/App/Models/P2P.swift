//
//  P2P.swift
//  Bits
//
//  Created by Valtteri Koskivuori on 12/09/2017.
//

import Vapor
import Foundation

//Simple custom P2P protocol handling
class P2P{
	
	var connections: [Client : WebSocket]
	//In SwiftCoin, the mempool consists of a FIFO-style array. No tx fees
	var memPool: [Transaction]
	
	init() {
		self.connections = [:]
		self.memPool = []
	}
	
	func broadcastBlock(block: Block) {
		
	}
	
	func broadcastTransaction(txn: Transaction) {
		
	}
	
	
	
	func broadcast(json: JSON) {
		
	}
}
