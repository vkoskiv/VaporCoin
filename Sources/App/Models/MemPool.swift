//
//  MemPool.swift
//  Run
//
//  Created by Valtteri on 15/04/2018.
//

import Foundation

class MemPool {
	private var pool: [Transaction]
	
	init() {
		self.pool = []
	}
	
	//Functions here for retrieving and storing transactions that are yet to be verified in a block
	
	func remove(txns: [Transaction]) {
		for txn in txns {
			self.pool = self.pool.filter { $0 != txn }
		}
	}
	
	func add(txns: [Transaction]) {
		for txn in txns {
			self.pool.append(txn)
		}
	}
	
	//Find and retrieve N transactions with biggest txn fees, starting from oldest
	func getBest(txns: Int) -> [Transaction] {
		//TODO
		return []
	}
}
