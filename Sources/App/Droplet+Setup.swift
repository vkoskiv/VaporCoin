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
			//Initialize miner
			let miner = Miner(coinbase: "coinbaseAddressNotImplementedYet", diffBits: 14, threadCount: 1)
			
			//Craft a new block to test mining with
			let myGroup = DispatchGroup()
			
			while true {
				let newBlock = Block(prevHash: state.getPreviousBlock().blockHash, depth: state.blockDepth, txns: [Transaction()], timestamp: Date().timeIntervalSince1970, difficulty: 5000, nonce: 0, hash: Data())
				myGroup.enter()
				miner.mine(block: newBlock) { foundBlock in
					miner.found(block: foundBlock) //Update state, print output
					myGroup.leave()
				}
				myGroup.wait()
			}
		}
    }
}
