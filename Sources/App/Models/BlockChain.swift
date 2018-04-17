//
//  BlockChain.swift
//  App
//
//  Created by Valtteri on 17/04/2018.
//

import Foundation

class BlockChain {
	
	//For now, just a in-memory array.
	//Eventually have an in-memory queue of an array of arrays of blocks
	//And then only store to DB when we TRUST a  block
	private var chain: [Block]
	
	var depth: Int
	
	init() {
		self.chain = []
		self.depth = 1
		
		//Append genesis
		self.chain.append(genesisBlock())
	}
	
	func append(_ block: Block) {
		if block.verify() {
			self.chain.append(block)
			self.depth += 1
		}
	}
	
	func getBlockWith(hash: Data) -> Block {
		let blocks = self.chain.filter { $0.blockHash == hash }
		if blocks.count > 1 {
			print("Found more than 1 block with the hash \(hash.hexString)")
			return Block()
		} else if blocks.count < 1 {
			print("Found no blocks with the hash \(hash.hexString).")
			return Block()
		}
		return blocks.first!
	}
	
	func getBlockWith(index: Int) -> Block {
		return self.chain[index]
	}
	
	func getPreviousBlock() -> Block {
		return self.chain[self.depth - 1]
	}
	
	func getLatestBlock() -> Block {
		return self.chain.last!
	}
}
