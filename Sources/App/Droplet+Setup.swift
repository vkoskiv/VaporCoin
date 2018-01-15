@_exported import Vapor
import Foundation

//Global client state
let state = State()

class HashingOperation: Operation {
    override var isAsynchronous: Bool {
        return true
    }
    
    
 }

extension Droplet {
    
    public func setup() throws {
        try setupRoutes()
        
    
        Miner.beginMiningOnSingleThread()

    }

    
}
