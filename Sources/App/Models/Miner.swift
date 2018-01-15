//
//  Miner.swift
//  App
//
//  Created by Valtteri Koskivuori on 04/01/2018.
//

import Foundation



// TODO - unit tests
// thread count 4 -> 4000
// hashDifficulty low + high
class Miner {
    
    static var debug = true
    
    //Address
    var coinbase: String
    var difficulty: Int64
    
    //Mining params
    var nonce: Int32 = 0
    var timeStamp: Double = Date().timeIntervalSince1970
    
    //Hardware params
    static var threadCount: Int = 1
    
    // Reduce to make mining faster
    static var hashDifficulty:String  = "000000"
    
    init(coinbase: String, diff: Int64, threadCount: Int) {
        if Miner.debug{
               print("Starting VaporCoin miner with \(threadCount) threads")
        }
        self.coinbase = coinbase
        self.difficulty = diff
        Miner.threadCount = threadCount
    }
    
    
    // This single entry point creates a VaporCoin Supervisor Thread - which is intended to  one have one worker thread.
    // N.B. the count in SupervisorThread includes main thread so count is 2  (but main thread isn't accessible from within vapor droplet).
     @objc static func beginMiningOnSingleThread(){
        ThreadSupervisor.createAndRunThread(target: Miner.self, selector: #selector(Miner.mine), object: nil)
    }
    
    // From here we are creating a ConcurrentOperation and queuing up to a single OperationQueue with concurrency threading /multi-threading .
    // We are using  OperationQueues instead DispatchQueues to organize / centralize cancelling of operations across threads.
    // TODO - investigate   let queue =  OperationQueue.main to work here.
    @objc static func mine(){
        
        if Miner.debug{
            print("Current thread \(Thread.current)")
            print("numberOfThreads:",ThreadSupervisor.numberOfThreads)
        }

        state.blockFound = false
        
        let miner = Miner(coinbase: "coinbaseAddressNotImplementedYet", diff: 20, threadCount: 4)
        let block = Block(prevHash: state.getPreviousBlock().blockHash, depth: state.blockChain.count, txns: [Transaction()], timestamp: Date().timeIntervalSince1970, difficulty: 5000, nonce: 0, hash: Data())
        
        block.nonce = 0
        block.blockHash = block.encoded().sha256
        
      
        // Here we're using the state.miningQueue so that we can sync up with the
        let queue =  state.hashingQueue

        queue.isSuspended = true
        queue.maxConcurrentOperationCount = Miner.threadCount
        
        if Miner.debug{
            print("BEGIN - queue:",queue.operationCount)
        }
        for psuedoThreadId in 0...Miner.threadCount-1{
            
            let op = ConcurrentOperation()
            
            op.completionBlock = {
                let candidate = block.newCopy()
                
                //Start each thread with a nonce at different spot
                candidate.nonce =  UInt64(psuedoThreadId) * (UINT64_MAX/UInt64(Miner.threadCount))
                candidate.depthTarget = state.blockChain.count
                
                while !candidate.blockHash.binaryString.hasPrefix(Miner.hashDifficulty) {
                    candidate.nonce += 1
                    candidate.timestamp = Date().timeIntervalSince1970
                    candidate.blockHash = candidate.encoded().sha256
                    if candidate.depthTarget != state.blockChain.count{
                        if Miner.debug {
                           print("depth target changed")
                        }
                        return
                    }

                    if op.isCancelled{
                        if Miner.debug {
                          print("cancelled")
                        }
                        return
                    }
                    if state.blockFound{
                         return
                    }
                    
                }
                
                
                if !state.blockFound {
                    queue.isSuspended = true
                    queue.cancelAllOperations()
                    state.miningQueue.cancelAllOperations()
//                    print("state.miningQueue.count:",state.miningQueue.operationCount)
                    self.blockFound(candidate)
                }
            }
            queue.addOperation(op)
        }
        
        if Miner.debug{
            print("END - queue:",queue.operationCount)
        }
        
        queue.isSuspended = false
    }
    
    // Thread Sanity Check - only add candidate block if another thread hasn't beat it to it
    // ie. this blockFound method can be called simulatenously across execution of threads
    
    @objc static func blockFound(_ block: Block) {

        let lastBlockHash = state.blockChain.last?.blockHash.binaryString
        // is this thread lagging - did the blockchain advance on another thread?
        if  lastBlockHash == block.prevHash.binaryString{
            
            if block.depthTarget == state.blockChain.count{
                if !state.blockFound{
                    state.blockFound = true
                    
//                    block.debug()
                    print("depth     : \(state.blockChain.count)") // TODO - logInfo - this should increase and not skip!!!
                    state.blocksSinceDifficultyUpdate += 1
                    state.blockChain.append(block)
//                    print("numberOfThreads:",ThreadSupervisor.numberOfThreads)
                    
                    state.miningQueue.cancelAllOperations()
                     let op = MiningOperation()
                    op.completionBlock = {
                        if !op.isCancelled{
                            Miner.mine()
                        }
                    }
                    if state.miningQueue.operationCount == 0{
                        state.miningQueue.addOperation(op)
                    }else{
                        print("potential dead lock....sleepng...:", state.miningQueue.operationCount )
                        sleep(1)
                        state.miningQueue.addOperation(op)
                    }

                }else{
                    if Miner.debug{
                       print("blockFound on other thread")
                    }
                }
            }
        }else{
            if Miner.debug{
                if Miner.debug{
                    print("dropping.... ")
                }
            }
        }
        

    }
    
    // N.B. if the miner stops and there's no working thread - need to tweak the timing
    // known issue - if the hashDifficulty is too big - this can stalled if we don't wait long enough for all operations to cancel.
    @objc static func drainMiningQueueAndStartAgain(){
        let difficultyHeight = useconds_t(Miner.hashDifficulty.count * threadCount*state.miningQueue.operationCount)
        state.miningQueue.cancelAllOperations()
//        let sleepCount:useconds_t = difficulty < 2000 ? 200000:difficulty*2000
        usleep(100000000 * difficultyHeight) // we need to give the some cycles to correctly cancel existing operations across threads - otherwise this thread can get caught up with cancelling - and basically miner runs out of things todo
        ThreadSupervisor.createAndRunThread(target: Miner.self, selector: #selector(mine), object: nil)


    }
}
