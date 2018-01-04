@_exported import Vapor
import Foundation

//Global client state
let state = State()
let miningEnabled = false

extension Droplet {
    public func setup() throws {
        try setupRoutes()
		
		//For now init state by reading value from there.
		print("BlockChain count: \(state.blockChain.count)")
		
		if miningEnabled {
			let miner = Miner(coinbase: "asdf", diff: 5000)
			//Craft a new block to test mining with
			
			while true {
				let newBlock = Block(prevHash: state.getPreviousBlock().blockHash, depth: state.blockDepth, txns: [Transaction()], timestamp: Date().timeIntervalSince1970, difficulty: 5000, nonce: 0, hash: Data())
				let minedBlock = miner.startWorker(block: newBlock)
				state.blockDepth += 1
				state.blocksSinceDifficultyUpdate += 1
				state.blockChain.append(minedBlock)
			}
		}
    }
}
