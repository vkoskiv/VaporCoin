@_exported import Vapor
import Foundation

//Global client state
let state = State()
let miningEnabled = true

extension Droplet {
    public func setup() throws {
        try setupRoutes()
		
		//For now init state by reading value from there.
		print("BlockChain count: \(state.blockChain.count)")
		
		if miningEnabled {
			let miner = Miner(coinbase: "asdf", diff: 5000)
			//Craft a new block to test mining with
			
			let myGroup = DispatchGroup()
			
			for i in 1...10 {
				print(i)
				let newBlock = Block(prevHash: state.getPreviousBlock().blockHash, depth: state.blockDepth, txns: [Transaction()], timestamp: Date().timeIntervalSince1970, difficulty: 5000, nonce: 0, hash: Data())
				myGroup.enter()
				miner.mineBlock(block: newBlock) { foundBlock in
					miner.blockFound(block: foundBlock) //Update state, print output
					myGroup.leave()
				}
			}
		}
    }
}
