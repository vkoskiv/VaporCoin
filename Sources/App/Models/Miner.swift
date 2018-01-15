//
//  Miner.swift
//  App
//
//  Created by Valtteri Koskivuori on 04/01/2018.
//

import Foundation



class Miner {
    
    //static let shared = Miner()
    
    //Address
    var coinbase: String
    var difficulty: Int64
    
    //Mining params
    var nonce: Int32 = 0
    var timeStamp: Double = Date().timeIntervalSince1970
    
    //Hardware params
    var threadCount: Int = 1
    
    init(coinbase: String, diff: Int64, threadCount: Int) {
        print("Starting VaporCoin miner with \(threadCount) threads")
        self.coinbase = coinbase
        self.difficulty = diff
        self.threadCount = threadCount
    }
    
    
    // This single entry point creates a VaporCoin Supervisor Thread - which is intended to  have ever have one thread.
    // N.B. the count in SupervisorThread includes main thread so count is 2 out (but main thread isn't accessible from within vapor droplet).
     @objc static func beginMiningOnSingleThread(){
        ThreadSupervisor.createAndRunThread(target: Miner.self, selector: #selector(Miner.mine), object: nil)
    }
    
    // From here we are creating a ConcurrentOperation and queuing up to a single OperationQueue with concurrency threading /multi-threads .
    // We are using  OperationQueues instead DispatchQueues to organize / centralize cancelling of operations across threads.
    // TODO - investigate   let queue =  OperationQueue.main to work here.
    @objc static func mine(){
        
        print("Current thread \(Thread.current)")
        print("numberOfThreads:",ThreadSupervisor.numberOfThreads)
     

        let miner = Miner(coinbase: "asdf", diff: 5000, threadCount: 4)
        let block = Block(prevHash: state.getPreviousBlock().blockHash, depth: state.blockChain.count, txns: [Transaction()], timestamp: Date().timeIntervalSince1970, difficulty: 5000, nonce: 0, hash: Data())
        
        block.nonce = 0
        block.blockHash = block.encoded().sha256
        
      
        // Here we're using the state.miningQueue so that we can sync up with the
        let queue =  state.miningQueue
        queue.isSuspended = true
        queue.maxConcurrentOperationCount = miner.threadCount
        
        print("BEGIN - queue:",queue.operationCount)
        for psuedoThreadId in 0...miner.threadCount-1{
            
            let op = HashingOperation()
            
            op.completionBlock = {
                let candidate = block.newCopy()
                
                //Start each thread with a nonce at different spot
                candidate.nonce =  UInt64(psuedoThreadId) * (UINT64_MAX/UInt64(miner.threadCount))
      
                func mineCandidateHash () {
                    candidate.nonce += 1
                    candidate.timestamp = Date().timeIntervalSince1970
                    candidate.blockHash = candidate.encoded().sha256
                    if op.isCancelled {
                        return
                    }
                    // We got one.
                    if candidate.blockHash.binaryString.hasPrefix("00"){
                        return
                    }
                    mineCandidateHash()
                }

                mineCandidateHash()

                if op.isCancelled {
                    return
                }else{
                    queue.isSuspended = true
                    queue.cancelAllOperations()
                     ThreadSupervisor.createAndRunThread(target: Miner.self, selector: #selector(Miner.blockFound), object: candidate)

                }
            }
            queue.addOperation(op)
        }
        
        print("END - queue:",queue.operationCount)
        queue.isSuspended = false
    }
    
    @objc static func blockFound(_ block: Block) {
        //Get user-readable date

        // Thread Sanity Check - only add candidate block if another thread hasn't beat it to it
        // ie. this blockFound method can be called simulatenously in runloop
        if state.blockChain.last?.blockHash.binaryString == block.prevHash.binaryString{
            let date = Date(timeIntervalSince1970: block.timestamp)
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-YYYY hh:mm:ss"
            //        let dateString = formatter.string(from: date)
            
            //        print("prevHash  : \(block.prevHash.hexString)")
            //        print("hash      : \(block.blockHash.hexString)")
            //        print("nonce     : \(block.nonce)")
            
            //        print("merkleRoot: \(block.merkleRoot.hexString)")
            //        print("timestamp : \(block.timestamp) (\(dateString))")
            //        print("targetDiff: \(block.target)\n")
            print("depth     : \(state.blockChain.count)")
            state.blocksSinceDifficultyUpdate += 1
            state.blockChain.append(block)
            self.drainMiningQueueAndStartAgain()
        }else{
                print("dropping.... ")
        }
        

    }
    
    @objc static func drainMiningQueueAndStartAgain(){
        
        state.miningQueue.cancelAllOperations()
        usleep(20000) // we need to give the mineCandidateHash some cycles to correctly cancel existing operations across threads - otherwise this thread can get caught up with cancelling - and basically miner runs out of things todo.
        print(">>> queue:",state.miningQueue.operationCount)
        ThreadSupervisor.createAndRunThread(target: self, selector: #selector(mine), object: nil)
    }
}
