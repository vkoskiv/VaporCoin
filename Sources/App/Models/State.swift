//
//  State.swift
//  Bits
//
//  Created by Valtteri Koskivuori on 12/09/2017.
//

import Foundation
import Vapor
import Transport
import Sockets

//Current client state
class State: Hashable {
    //Currently connected peers and their respective WS
    var peers: [PeerState: WebSocket]
    //Known hostnames
    var knownHosts: [String]
    //Pool of pending transactions to be processed
    var memPool: [Transaction]
    
    //For now, just a in-memory array.
    //Eventually have an in-memory queue of an array of arrays of blocks
    //And then only store to DB when we TRUST a  block
    
    private var internalChain :  [Block] = []
    
    var blockChain = SynchronizedArray<Block>()
    
    var clientVersion = 1
    var clientType    = "hype-fullnode"
    
    var signature: Wallet? = nil
    
    var p2pProtocol: P2PProtocol
    var minerProtocol: MinerProtocol
    
    var outboundConnections: Int {
        return self.peers.count
    }
    
    let version: Int = 1
    
    var currentDifficulty: Int64
    var blocksSinceDifficultyUpdate: Int
    
    
    private var _blockFound = false
    var blockFound:Bool{
        get {
            return blockChain.queue.sync {
                _blockFound
            }
        }
        set {
            blockChain.queue.sync {
                _blockFound = newValue
            }
        }
    }
    
    private var _threadedHashingQueue = OperationQueue()
    var hashingQueue:OperationQueue{
        get {
            return blockChain.queue.sync {
                _threadedHashingQueue
            }
        }
        set {
            blockChain.queue.sync {
                _threadedHashingQueue = newValue
            }
            
        }
    }
    
    private var _miningQueue = OperationQueue()
    var miningQueue:OperationQueue{
        get {
            return blockChain.queue.sync {
                _miningQueue
            }
        }
        set {
            blockChain.queue.sync {
                _miningQueue = newValue
            }
            
        }
    }
    
    // In some difficulties - blocks were being found simulatenously across threads.
    // this serial queue was designed to force execution into a serial queue & avoid a potential dead lock situation.
    private var _blockFoundQueue = OperationQueue()
    var blockFoundQueue:OperationQueue{
        get {
            return blockChain.queue.sync {
                _blockFoundQueue
            }
        }
        set {
            blockChain.queue.sync {
                _blockFoundQueue = newValue
            }
        }
    }
    

    
    init() {
        print("Initializing client state")
        self.peers = [:]
        
        self.knownHosts = []
        self.knownHosts.append("ws://192.168.1.101:8080/p2p")
        //self.knownHosts.append("proteus.vkoskiv.com")
        //self.knownHosts.append("triton.vkoskiv.com")
        
        self.memPool = []
        self.blockChain = SynchronizedArray<Block>()
        self.blockChain.append(genesisBlock())
        print("GenesisBlockHash: \(blockChain.first!.blockHash.hexString)")
        self.p2pProtocol = P2PProtocol()
        self.minerProtocol = MinerProtocol()
        
        //Blockchain state params
        self.currentDifficulty = 1
        self.blocksSinceDifficultyUpdate = 1

        _miningQueue.maxConcurrentOperationCount = 1
        _blockFoundQueue.maxConcurrentOperationCount = 1
        
        //self.initConnections()
        
        //Set up initial client conns
        /*DispatchQueue.global(qos: .background).async {
         self.initConnections()
         self.startSync()
         }*/
        
        //Start syncing on a background thread
        /*DispatchQueue.global(qos: .background).async {
         
         }*/
        
        /*var pubKey: CryptoKey
         var privKey: CryptoKey
         do {
         print("Loading crypto keys")
         pubKey = try CryptoKey(path: "/Users/vkoskiv/coinkeys/public.pem", component: .publicKey)
         privKey = try CryptoKey(path: "/Users/vkoskiv/coinkeys/private.pem", component: .privateKey(passphrase:nil))
         
         self.signature = ClientSignature(pub: pubKey, priv: privKey)
         } catch {
         print("Crypto keys not found!")
         }*/
    }
    
    func cancelAllMiningOperations(){
        miningQueue.cancelAllOperations()
    }
    func startSync() {
        //Query other nodes for blockchain status, and then sync until latest block
        print("Starting background sync, from block \(state.blockChain.count)")
        self.p2pProtocol.sendRequest(request: .getBlock, to: nil, 0)
    }
    
    //Get new peers AND get current network status (difficulty, block depth)
    func queryPeers() {
        //Query for new peers to add to list
        //TODO: A ping request to see if node is alive + versioning
        print("Querying for more hostnames from peers")
        for (p, _) in peers {
            //json = self.p2pProtocol.sendRequest(request: RequestType.getPeers, to: p, nil)
            //FIXME: Why can't we pass nil to the generic param??
            self.p2pProtocol.sendRequest(request: RequestType.getPeers, to: p, NSNull.self)
        }
    }
    
    //Outbound connections, this should be max 8 connections
    //Note, that these outbound connections are used *only* for outgoing messages.
    //All incoming ones are going thru the normal input socket
    func initConnections() {
        //Hard-coded, known nodes to start querying state from
        print("Initializing connections")
        for hostname in self.knownHosts {
            DispatchQueue.global(qos: .background).async {
                do {
                    print("Connecting to \(hostname)...")
                    try WebSocketFactory.shared.connect(to: hostname) { (websocket: WebSocket) throws -> Void in
                        print("Connected to \(hostname)")
                        //Connected
                        //TODO: WebSocket pinging and stuff
                        //Here we query the client for clientVersion, type...
                        let newPeer = PeerState(hostname: hostname, clientVersion: 1, clientType: "eee")
                        state.peers.updateValue(websocket, forKey: newPeer)
                    }
                } catch {
                    print("Failed to connect to \(hostname), error: \(error)")
                }
            }
            
        }
        //queryPeers()
    }
    
    var hashValue: Int {
        //TODO: Get a unique hashvalue
        return self.version
    }
    
    //MARK: Interact with blockchain
    func getBlockWithHash(hash: Data) -> Block {
        let blocks = self.blockChain.syncFilter { $0.blockHash == hash }
        if blocks.count > 1 {
            print("Found more than 1 block with this hash. Yer blockchain's fucked.")
            return Block()
        } else if blocks.count < 1 {
            print("Found less than 1 block with this hash.")
            return Block()
        }
        return blocks.first!
    }
    
    func getPreviousBlock() -> Block {
        return self.blockChain.last!
//        if self.blockChain.count > self.blockChain.count - 1{
//
//        }else{
//            print("WARNING - self.blockDepth -1 < self.blockChain.count ")
//            print("self.blockChain.count:",self.blockChain.count)
//           print("self.blockDepth:",self.blockDepth)
//            return Block()
//        }
        
    }
    
    func getBlockWithIndex(idx: Int) -> Block {
        return self.blockChain[idx]
    }
    
    func getLatestBlock() -> Block {
        return self.blockChain.last!
    }
    
    func updateDifficulty() {
        //Look at how long last 60 blocks took, and update difficulty
        let startTime = self.blockChain[self.blockChain.endIndex - 60].timestamp
        let timeDiff = self.blockChain.last!.timestamp - startTime
        print("Last 60 blocks took \(timeDiff)s, target is 3600s")
        //Target is 3600s (1 hour)
        print("Difficulty before: \(self.currentDifficulty)")
        self.currentDifficulty *= Int64(3600 / timeDiff)
        print("Difficulty after:  \(self.currentDifficulty)")
        self.blocksSinceDifficultyUpdate = 0
    }
    
}

func ==(lhs: State, rhs: State) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
