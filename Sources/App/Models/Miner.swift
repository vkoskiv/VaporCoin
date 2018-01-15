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
// debug on / off  - this can effect speeds of mining / delays

class Miner {
    
    static var debug = false
    
    //Address
    var coinbase: String
    var difficulty: Int64
    
    //Mining params
    var nonce: Int32 = 0
    var timeStamp: Double = Date().timeIntervalSince1970
    
    //Hardware params
    static var threadCount: Int = 1
    
    // Reduce to make mining faster
    static var hashDifficulty:String  = "00000"
    
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
        state.blockFoundQueue.cancelAllOperations()
        
        let miner = Miner(coinbase: "coinbaseAddressNotImplementedYet", diff: 20, threadCount: 4)
        let block = Block(prevHash: state.getPreviousBlock().blockHash, depth: state.blockChain.count, txns: [Transaction()], timestamp: Date().timeIntervalSince1970, difficulty: 5000, nonce: 0, hash: Data())
        
        block.nonce = 0
        block.blockHash = block.encoded().sha256
        
      
        // Here we're using the state.hashingQueue so that we cancel uniformly across threads if a single thread finds a block.
        let hashQueue =  state.hashingQueue
        hashQueue.isSuspended = true
        hashQueue.maxConcurrentOperationCount = Miner.threadCount
        
        if Miner.debug{
            print("BEGIN - queue:",hashQueue.operationCount)
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
                
                
                // New Candidate Block discovered - why the blockFoundQueue ?
                // without - it's possible two threads can simulatenously enter the blockFound method.
                if !state.blockFound {
                    hashQueue.isSuspended = true
                    hashQueue.cancelAllOperations()
                    state.miningQueue.cancelAllOperations()

                    
                    let newBlockOp = BlockFoundOperation()
                    newBlockOp.completionBlock = {
                        if !newBlockOp.isCancelled{
                            Miner.blockFound(candidate)
                        }
                    }
                    state.blockFoundQueue.cancelAllOperations()
                    // this should be singular / serial queue
                    state.blockFoundQueue.addOperation(newBlockOp)
                    
                }
            }
            hashQueue.addOperation(op)
        }
        
        if Miner.debug{
            print("END - queue:",hashQueue.operationCount)
        }
        
        hashQueue.isSuspended = false
    }
    
    // Thread Sanity Check - only add candidate block if another thread hasn't beat it to it
    // ie. this blockFound method can be called simulatenously across execution of threads
    
    @objc static func blockFound(_ block: Block) {

        let lastBlockHash = state.blockChain.last?.blockHash.binaryString
        // is this thread lagging - did the candidate blockchain advance on another thread?
        if  lastBlockHash == block.prevHash.binaryString{
            
            if block.depthTarget == state.blockChain.count{
                if !state.blockFound{
                    state.blockFound = true
                    
                    block.debug()
                    print("depth     : \(state.blockChain.count)") // TODO - logInfo - this should increase and not skip!!!
                    state.blocksSinceDifficultyUpdate += 1
                    state.blockChain.append(block)
                    
                    state.blockFoundQueue.cancelAllOperations()
                  
                   
                   Miner.queueUpMiningOperation()

                }else{
                    if Miner.debug{
                       print("blockFound on other thread")
                    }
                }
            }
        }else{
            if Miner.debug{
                print("dropping.... :",state.miningQueue.operationCount)
            }
           
            // recover from cancelled operations.
            if (state.miningQueue.operationCount == 0){
                print("attempting to recover")
                sleep(1)
                if !state.blockFound{
                    state.miningQueue.cancelAllOperations()
                    Miner.queueUpMiningOperation()
                }
            }
        }
    }
    
    // This queue allows  the canceling of  mining across threads.
    // without this - we can get thread explosion on lower difficulties.
    // basically - this is a serial queue - that should only ever have one miningOperation.
    @objc static func queueUpMiningOperation(){
        
        let op = MiningOperation()
        op.completionBlock = {
            if !op.isCancelled{
                Miner.mine()
            }
        }
        if state.miningQueue.operationCount == 0{
            state.miningQueue.addOperation(op)
        }else{
            state.miningQueue.cancelAllOperations()
            state.blockFoundQueue.cancelAllOperations()
            state.hashingQueue.cancelAllOperations()
            print("potential dead lock....sleeping...:", state.miningQueue.operationCount )
            sleep(1)
            state.miningQueue.addOperation(op)
        }
    }

}
