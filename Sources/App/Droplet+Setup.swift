@_exported import Vapor
import Foundation

//Global client state
let state = State()

class ConcurrentOperation: Operation {
    override var isAsynchronous: Bool {
        return true
    }
 }

class MiningOperation: Operation {
    override var isAsynchronous: Bool {
        return false
    }
}
class BlockFoundOperation: Operation {
    override var isAsynchronous: Bool {
        return false
    }
}


extension Droplet {
    
    public func setup() throws {
        try setupRoutes()
        
    
        Miner.beginMiningOnSingleThread()

    }

    
}
