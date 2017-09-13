//
//  Transaction.swift
//  VaporCoin
//
//  Created by Valtteri Koskivuori on 11/09/2017.
//

import Vapor
import Foundation

class Address {
	
}

class Transaction: NSObject, NSCoding {
	
	//MARK: Swift encoding logic
	
	public convenience required init?(coder aDecoder: NSCoder) {
		let type = aDecoder.decodeObject(forKey: "type") as! txType
		let inputAmount = aDecoder.decodeInt64(forKey: "inputAmount")
		let outputAmount = aDecoder.decodeInt64(forKey: "outputAmount")
		let from = aDecoder.decodeObject(forKey: "from") as! Address
		let senderPubKey = aDecoder.decodeObject(forKey: "senderPubKey") as! Address
		let senderSignature = aDecoder.decodeObject(forKey: "senderSignature") as! ClientSignature
		
		let to = aDecoder.decodeObject(forKey: "to") as! Address
		let blockHash = aDecoder.decodeObject(forKey: "hash") as! Data
		
		self.init(type: type, inputAmount: inputAmount, outputAmount: outputAmount, from: from, senderPubKey: senderPubKey, senderSignature: senderSignature, to: to, hash: blockHash)
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(type, forKey: "type")
		aCoder.encode(inputAmount, forKey: "inputAmount")
		aCoder.encode(outputAmount, forKey: "outputAmount")
		aCoder.encode(from, forKey: "from")
		aCoder.encode(senderPubKey, forKey: "senderPubKey")
		aCoder.encode(senderSignature, forKey: "senderSignature")
		aCoder.encode(to, forKey: "to")
		aCoder.encode(txnHash, forKey: "blockHash")
	}
	
	//Class params
	enum txType {
		case transaction
		case blockReward
		case dataRecord //Arbitrary data on the blockchain
	}
	
	var type: txType
	// 100,000,000 = 1.0 VaporCoins
	//Difference between inputAmt and outputAmt goes to miner as fee
	//TODO: Make sure output isn't greater than input
	var inputAmount: Int64
	var outputAmount: Int64
	
	var transactionFee: Int64 {
		return inputAmount - outputAmount
	}
	
	//From and senderpubkey are optional. BlockRewards don't need them.
	var from: Address? = nil
	var senderPubKey: Address? = nil //TODO: Keys and generation
	var senderSignature: ClientSignature
	
	var to: Address
	var txnHash: Data
	
	override init() {
		self.type = .transaction
		self.inputAmount = 0
		self.outputAmount = 0
		self.from = Address()
		self.senderPubKey = Address()
		self.senderSignature = ClientSignature()
		
		self.to = Address()
		self.txnHash = Data()
	}
	
	init(type: txType, inputAmount: Int64, outputAmount: Int64, from: Address, senderPubKey: Address, senderSignature: ClientSignature, to: Address, hash: Data) {
		self.type = type
		self.inputAmount = inputAmount
		self.outputAmount = outputAmount
		self.from = from
		self.senderPubKey = senderPubKey
		self.senderSignature = senderSignature
		self.to = to
		self.txnHash = hash
	}
	
	func encoded() -> Data {
		//TODO
		return NSKeyedArchiver.archivedData(withRootObject: self)
	}
	
	func newTransaction() -> Transaction {
		return Transaction()
	}
	
	func newBlockReward() -> Transaction {
		return Transaction()
	}
}
