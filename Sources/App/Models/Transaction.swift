//
//  Transaction.swift
//  VaporCoin
//
//  Created by Valtteri Koskivuori on 11/09/2017.
//

import Vapor
import Foundation

public enum transactionType {
	case coinbase //Special, miner reward
	case normal   //Regular utxo value transaction
	case data     //Arbitrary data?
}

//TODO: Possibly put value, from, recipient into a payload struct and support other types of txn
//hash, sig and pubkey should exist in all transactions anyway

class Transaction: NSObject, NSCoding {
	
	// 100,000,000 = 1.0 VaporCoins (8 decimal places)
	
	var value: Int64
	
	var from: Data
	var recipient: Data
	
	var txnType: transactionType
	
	var txnHash: Data { //Hash of transaction
		return self.encoded().sha256
	}
	
	//These are both optional - Coinbase transactions don't need em
	var senderSig: Data? //txnHash signed with privKey
	var senderPubKey: Data? //The key that can "decrypt" senderSig
	
	override init() {
		self.value = 0
		
		self.from = Data()
		self.recipient = Data()
		
		self.txnType = .normal
		
		self.senderSig = Data()
		self.senderPubKey = Data()
	}
	
	init(value: Int64, from: Data, recipient: Data, txnType: transactionType, senderSig: Data?, senderPubKey: Data?) {
		self.value = value
		
		self.from = from
		self.recipient = recipient
		
		self.txnType = txnType
		
		self.senderSig = senderSig
		self.senderPubKey = senderPubKey
	}
	
	func newCoinbase(address: Wallet) -> Transaction {
		//Get current block reward from Consensus protocol
		let br = currentBlockReward()
		
		guard let address = address.pubKey else {
			print("No address for coinbase!")
			return Transaction()
		}
		
		let txn = Transaction(value: br,
		                      from: Data(),
		                      recipient: address,
		                      txnType: .coinbase,
		                      senderSig: nil,
		                      senderPubKey: nil)
		return txn
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
	
	func getTransactionWith(hash: Data) -> Transaction {
		for block in state.blockChain {
			for txn in block.txns {
				if txn.txnHash == hash {
					return txn
				}
			}
		}
		print("no txn found with \(hash)")
		return Transaction()
	}
	
	func encoded() -> Data {
		return NSKeyedArchiver.archivedData(withRootObject: self)
	}
	
	//MARK: Swift encoding logic
	
	public convenience required init?(coder aDecoder: NSCoder) {
		
		let value = aDecoder.decodeInt64(forKey: "value")
		
		let from = aDecoder.decodeObject(forKey: "from") as! Data
		let recipient = aDecoder.decodeObject(forKey: "recipient") as! Data
		
		let txnType = aDecoder.decodeObject(forKey: "type") as! transactionType
		
		let senderSig = aDecoder.decodeObject(forKey: "sendersig") as! Data
		let senderPubKey = aDecoder.decodeObject(forKey: "senderpubkey") as! Data
		
		self.init(value: value, from: from, recipient: recipient, txnType: txnType, senderSig: senderSig, senderPubKey: senderPubKey)
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(self.value, forKey: "value")
		aCoder.encode(self.from, forKey: "from")
		aCoder.encode(self.recipient, forKey: "recipient")
		aCoder.encode(self.txnType, forKey: "type")
		aCoder.encode(self.senderSig, forKey: "sendersig")
		aCoder.encode(self.senderPubKey, forKey: "senderpubkey")
	}
}
