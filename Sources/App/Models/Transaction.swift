//
//  Transaction.swift
//  VaporCoin
//
//  Created by Valtteri Koskivuori on 11/09/2017.
//

import Vapor
import Foundation

class TransactionInput {
	var value: Int64
	var txHash: Data
	
	init(value: Int64, hash: Data) {
		self.value = value
		self.txHash = hash
	}
}

class TransactionOutput {
	var value: Int64
	var txHash: Data
	
	init(value: Int64, hash: Data) {
		self.value = value
		self.txHash = hash
	}
}

public enum transactionType {
	case coinbase //Special, miner reward
	case normal   //Regular utxo value transaction
	case data     //Arbitrary data?
}

class Transaction: NSObject, NSCoding {
	
	// 100,000,000 = 1.0 VaporCoins
	
	var inputs: [Transaction]
	var outputs: [Transaction]
	
	var from: Data
	var senderPubKey: Data
	var senderSignature: Data
	
	var recipient: Data
	var txnHash: Data
	
	override init() {
		self.inputs = []
		self.outputs = []
		self.from = Data()
		self.senderPubKey = Data()
		self.senderSignature = Data()
		
		self.recipient = Data()
		self.txnHash = Data()
	}
	
	init(inputs: [Transaction], outputs: [Transaction], from: Data, senderPubKey: Data, senderSignature: Data, recipient: Data, hash: Data) {
		self.inputs = inputs
		self.outputs = outputs
		self.from = from
		self.senderPubKey = senderPubKey
		self.senderSignature = senderSignature
		self.recipient = recipient
		self.txnHash = hash
	}
	
	func newTranscation(source: Wallet, dest: Wallet, input: Int64, output: Int64) -> Transaction {
		//TODO
		
		//Get valid inputs
		//Construct valid outputs
		//Construct transaction
		
		return Transaction()
	}
	
	func getInputs(forOwner: Wallet, forAmount: Int64) -> [Transaction] {
		//Get inputs
		//Then map filter out ones that have been spent
		//for tx in block.txns {
		//	  state.memPool = state.memPool.filter { $0 != tx}
		//}

		//Then take required amount starting from oldest
		
		//let allAvailableTransactions = state.blockChain.filter { $0.txns.filter { $0.outputs.filter { $0.recipient.address == forOwner.address } } }
		
		var allAvailableTransactions: [Transaction] = []
		
		//Get all past input transactions of the sender
		for block in state.blockChain {
			for txn in block.txns {
				if txn.recipient == forOwner.address {
					allAvailableTransactions.append(txn)
				}
			}
		}
		
		//Get all spent transactions
		for block in state.blockChain {
			for txn in block.txns {
				if txn.senderPubKey == forOwner.pubKey {
					
				}
			}
		}
		
		/*for block in state.blockChain {
			for txn in block.txns {
				if txn.senderPubKey == forOwner.pubKey {
					
				}
			}
		}*/
		
		return [Transaction()]
	}
	
	func encoded() -> Data {
		return NSKeyedArchiver.archivedData(withRootObject: self)
	}
	
	//MARK: Swift encoding logic
	
	public convenience required init?(coder aDecoder: NSCoder) {
		let inputs = aDecoder.decodeObject(forKey: "inputs") as! [Transaction]
		let outputs = aDecoder.decodeObject(forKey: "outputs") as! [Transaction]
		let from = aDecoder.decodeObject(forKey: "from") as! Data
		let senderPubKey = aDecoder.decodeObject(forKey: "senderPubKey") as! Data
		let senderSignature = aDecoder.decodeObject(forKey: "senderSignature") as! Data
		
		let recipient = aDecoder.decodeObject(forKey: "recipient") as! Data
		let hash = aDecoder.decodeObject(forKey: "hash") as! Data
		
		self.init(inputs: inputs, outputs: outputs, from: from, senderPubKey: senderPubKey, senderSignature: senderSignature, recipient: recipient, hash: hash)
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(inputs, forKey: "inputs")
		aCoder.encode(outputs, forKey: "outputs")
		aCoder.encode(from, forKey: "from")
		aCoder.encode(senderPubKey, forKey: "senderPubKey")
		aCoder.encode(senderSignature, forKey: "senderSignature")
		aCoder.encode(recipient, forKey: "recipient")
	}
}
