@_exported import Vapor
import Foundation

//Global client state
let state = State()

extension Droplet {
	public func setup() throws {
		try setupRoutes()
		
		//For now init state by reading value from there.
		print("BlockChain count: \(state.blockChain.count)")
		
		let miner = Miner(coinbase: "notImplemented", diffBits: 14, threadCount: 1)
		miner.isMining = false
	}
}
