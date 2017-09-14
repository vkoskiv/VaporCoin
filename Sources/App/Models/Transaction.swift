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
	
	//MARK: Class
	
	// 100,000,000 = 1.0 VaporCoins
	//Difference between inputAmt and outputAmt goes to miner as fee
	//TODO: Make sure output isn't greater than input
	var inputs: [Transaction]
	var outputs: [Transaction]
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
		self.inputAmount = 0
		self.outputAmount = 0
		self.inputs = []
		self.outputs = []
		self.from = Address()
		self.senderPubKey = Address()
		self.senderSignature = ClientSignature()
		
		self.to = Address()
		self.txnHash = Data()
	}
	
	init(inputs: [Transaction], outputs: [Transaction], inputAmount: Int64, outputAmount: Int64, from: Address, senderPubKey: Address, senderSignature: ClientSignature, to: Address, hash: Data) {
		self.inputs = inputs
		self.outputs = outputs
		self.inputAmount = inputAmount
		self.outputAmount = outputAmount
		self.from = from
		self.senderPubKey = senderPubKey
		self.senderSignature = senderSignature
		self.to = to
		self.txnHash = hash
	}
	
	func newTranscation(source: ClientSignature, dest: ClientSignature, input: Int64, output: Int64) -> Transaction {
		//TODO
		return Transaction()
	}
	
	func getInputs(forOwner: ClientSignature, forAmount: Int64) -> [Transaction] {
		//Get inputs
		//Then map filter out ones that have been spent
		//for tx in block.txns {
		//	  state.memPool = state.memPool.filter { $0 != tx}
		//}

		//Then take required amount starting from oldest
		return [Transaction()]
	}
	
	func verify() -> Bool {
		//Check that output <= input
		//Check timestamp
		//Check addresses?
		return false
	}
	
	func encoded() -> Data {
		return NSKeyedArchiver.archivedData(withRootObject: self)
	}
	
	//MARK: Swift encoding logic
	
	public convenience required init?(coder aDecoder: NSCoder) {
		let inputs = aDecoder.decodeObject(forKey: "inputs") as! [Transaction]
		let outputs = aDecoder.decodeObject(forKey: "outputs") as! [Transaction]
		let inputAmount = aDecoder.decodeInt64(forKey: "inputAmount")
		let outputAmount = aDecoder.decodeInt64(forKey: "outputAmount")
		let from = aDecoder.decodeObject(forKey: "from") as! Address
		let senderPubKey = aDecoder.decodeObject(forKey: "senderPubKey") as! Address
		let senderSignature = aDecoder.decodeObject(forKey: "senderSignature") as! ClientSignature
		
		let to = aDecoder.decodeObject(forKey: "to") as! Address
		let hash = aDecoder.decodeObject(forKey: "hash") as! Data
		
		self.init(inputs: inputs, outputs: outputs, inputAmount: inputAmount, outputAmount: outputAmount, from: from, senderPubKey: senderPubKey, senderSignature: senderSignature, to: to, hash: hash)
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(inputs, forKey: "inputs")
		aCoder.encode(outputs, forKey: "outputs")
		aCoder.encode(inputAmount, forKey: "inputAmount")
		aCoder.encode(outputAmount, forKey: "outputAmount")
		aCoder.encode(from, forKey: "from")
		aCoder.encode(senderPubKey, forKey: "senderPubKey")
		aCoder.encode(senderSignature, forKey: "senderSignature")
		aCoder.encode(to, forKey: "to")
	}
}
